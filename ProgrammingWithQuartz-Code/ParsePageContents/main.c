/*
*  File:    main.c
*  
*  Copyright:  Copyright © 2005 Apple Computer, Inc., All Rights Reserved
* 
*  Disclaimer:  IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in 
*        consideration of your agreement to the following terms, and your use, installation, modification 
*        or redistribution of this Apple software constitutes acceptance of these terms.  If you do 
*        not agree with these terms, please do not use, install, modify or redistribute this Apple 
*        software.
*
*        In consideration of your agreement to abide by the following terms, and subject to these terms, 
*        Apple grants you a personal, non-exclusive license, under Apple's copyrights in this 
*        original Apple software (the "Apple Software"), to use, reproduce, modify and redistribute the 
*        Apple Software, with or without modifications, in source and/or binary forms; provided that if you 
*        redistribute the Apple Software in its entirety and without modifications, you must retain this 
*        notice and the following text and disclaimers in all such redistributions of the Apple Software. 
*        Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to 
*        endorse or promote products derived from the Apple Software without specific prior written 
*        permission from Apple.  Except as expressly stated in this notice, no other rights or 
*        licenses, express or implied, are granted by Apple herein, including but not limited to any 
*        patent rights that may be infringed by your derivative works or by other works in which the 
*        Apple Software may be incorporated.
*
*        The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR 
*        IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY 
*        AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE 
*        OR IN COMBINATION WITH YOUR PRODUCTS.
*
*        IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
*        DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
*        OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
*        REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER 
*        UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN 
*        IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*/

#include <ApplicationServices/ApplicationServices.h>

typedef struct MyDataScan
{
    size_t numImagesWithColorThisPage;
    size_t numImageMasksThisPage;
    size_t numImagesMaskedWithMaskThisPage;
    size_t numImagesMaskedWithColorsThisPage;
}MyDataScan;

static void printPageResults(FILE *outFile, MyDataScan myData, size_t pageNum)
{
    if(myData.numImagesWithColorThisPage)
		fprintf(outFile, 
			"Found %zd images with intrinsic color on Page %zd.\n", 
			myData.numImagesWithColorThisPage,
			pageNum);
    if(myData.numImageMasksThisPage)
		fprintf(outFile, 
			"Found %zd image masks on Page %zd.\n", 
			myData.numImageMasksThisPage,
			pageNum);
    if(myData.numImagesMaskedWithMaskThisPage)
		fprintf(outFile, 
			"Found %zd images masked with masks on Page %zd.\n", 
			myData.numImagesMaskedWithMaskThisPage,
			pageNum);
    if(myData.numImagesMaskedWithColorsThisPage)
		fprintf(outFile, 
			"Found %zd images masked with colors on Page %zd.\n", 
			myData.numImagesMaskedWithColorsThisPage,
			pageNum);
}

static void printDocResults(FILE *outFile, size_t totPages, 
				    size_t totImages)
{
    fprintf(outFile, 
		"\nSummary: %zd page document contains %zd images.\n\n", 
			totPages, totImages);

}
void checkImageType(CGPDFDictionaryRef imageDict, 
								MyDataScan *myScanDataP)
{
    CGPDFBoolean isMask;
    bool hasMaskKey;
    CGPDFObjectRef object;
    /* If it is an image mask, the dictionary has a key 
		/ImageMask with a boolean true or it has
		a key /IM with a boolean true. */
	hasMaskKey = CGPDFDictionaryGetBoolean(imageDict, "ImageMask", &isMask);
	if(!hasMaskKey)
		hasMaskKey = CGPDFDictionaryGetBoolean(imageDict, "IM", &isMask);
	
    if(hasMaskKey && isMask){
	    myScanDataP->numImageMasksThisPage++;
	    return;
    }
    
    // If image is masked with an alpha image it has an SMask entry.
    if(CGPDFDictionaryGetObject(imageDict, "SMask", &object)){
		// This object must be an XObject that is an image.
		// This code assumes the PDF is well formed in this regard.
	    myScanDataP->numImagesMaskedWithMaskThisPage++;
	    return;
    }

    // If this image is masked with an image or with colors it has 
    // a Mask entry.
    if(CGPDFDictionaryGetObject(imageDict, "Mask", &object)){
		// If the object is an XObject then the mask is an image. 
		// If it is an array, the mask is an array of colors.
		CGPDFObjectType type = CGPDFObjectGetType(object);
		// Check if it is a stream type which it must be to be an XObject.
		if(type == kCGPDFObjectTypeStream)
	    		myScanDataP->numImagesMaskedWithMaskThisPage++;
		else if(type == kCGPDFObjectTypeArray)
	    		myScanDataP->numImagesMaskedWithColorsThisPage++;
		else
			fprintf(stderr,	"Mask entry in Image object is not well formed!\n");
		
		return;
    }
    // This image is not a mask, is not masked with another image or 
    // color so it must be an image with intrinsic color with no mask.
    myScanDataP->numImagesWithColorThisPage++;
}

/*	The "Do" operator consumes one value off the stack, the name of 
 	the object to execute. The name is a resource in the resource
 	dictionary of the page and the object corresponding to that name 
 	is an XObject. The most common types of XObjects are either
 	Form objects or Image objects. This code only counts images.
    
	Note that forms, patterns, and potentially other resources contain
	images. This code only counts the top level images in a PDF document,
	not images embedded in other resources. */
void myOperator_Do(CGPDFScannerRef s, void *info)
{
    // Check to see if this is an image or not.
    const char *name;
    CGPDFObjectRef xobject;
    CGPDFDictionaryRef dict;
    CGPDFStreamRef stream;
    CGPDFContentStreamRef cs = CGPDFScannerGetContentStream(s);
    
    // The Do operator takes a name. Pop the name off the
    // stack. If this fails then the argument to the 
    // Do operator is not a name and is therefore invalid!
    if(!CGPDFScannerPopName(s, &name)){
		fprintf(stderr, "Couldn't pop name off stack!\n"); 
		return;
    }
    // Get the resource with type "XObject" and the name
    // obtained from the stack.
    xobject = CGPDFContentStreamGetResource(cs, "XObject", name);
    if(!xobject){
		fprintf(stderr, "Couldn't get XObject with name %s\n", name);
		return;
    }

    // An XObject must be a stream so obtain the value from the xobject
    // as if it were a stream. If this fails, the PDF is malformed.
    if (!CGPDFObjectGetValue(xobject, kCGPDFObjectTypeStream, &stream)){
		fprintf(stderr, "XObject '%s' is not a stream!\n", name);
		return;
    }
    // Streams consist of a dictionary and the data associated
    // with the stream. This code only cares about the dictionary.
    dict = CGPDFStreamGetDictionary(stream);
    if(!dict){
		fprintf(stderr, 
			"Couldn't obtain dictionary from stream %s!\n", name);
		return;
    }
    // An XObject dict has a Subtype that indicates what kind it is.
    if(!CGPDFDictionaryGetName(dict, "Subtype", &name)){
		fprintf(stderr, "Couldn't get SubType of dictionary object!\n");
		return;
    }
    
    // This code is interested in the "Image" Subtype of an XObject.
    // Check whether this object has Subtype of "Image".
    if(strcmp(name, "Image") != 0){
		// The Subtype is not "Image" so this must be a form 
		// or other type of XObject.
		return;
    }
    
    // This is an Image so figure out what variety of image it is.
    checkImageType(dict, (MyDataScan *)info);
    
}

// This callback handles inline images. Inline images end with the 
// "EI" operator.
void myOperator_EI(CGPDFScannerRef s, void *info)
{
    CGPDFStreamRef stream;
    CGPDFDictionaryRef dict;
    // When the scanner encounters the EI operator, it has a
    // stream corresponding to the image on the operand stack.
    // This code pops the stream off the stack in order to
    // examine it.
    if(!CGPDFScannerPopStream(s, &stream)){
		fprintf(stderr, "Couldn't create stream from inline image!\n");
		return;
    }
    // Get the image dictionary from the stream.
    dict = CGPDFStreamGetDictionary(stream);
    if(!dict){
		fprintf(stderr, "Couldn't get dict from inline image stream!\n");
		return;
    }
    // By definition the stream passed to EI is an image so
    // pass it to the code to check the type of image.
    checkImageType(dict, (MyDataScan *)info);

}

static CGPDFOperatorTableRef createMyOperatorTable(void)
{
    // Create a new operator table.
    CGPDFOperatorTableRef myTable = CGPDFOperatorTableCreate();
    // Add a callback for the "Do" operator.
    CGPDFOperatorTableSetCallback(myTable, "Do", myOperator_Do);
    // Add a callback for the "EI" operator.
    CGPDFOperatorTableSetCallback(myTable, "EI", myOperator_EI);
    return myTable;
}

void dumpPageStreams(CFURLRef url, FILE *outFile)
{
    CGPDFDocumentRef pdfDoc = NULL;
    CGPDFOperatorTableRef table = NULL;
    MyDataScan myData;
    size_t totalImages, totPages, i;

    // Create a CGPDFDocumentRef from the input PDF file.
    pdfDoc = CGPDFDocumentCreateWithURL(url);
    if(!pdfDoc){
		fprintf(stderr, "Couldn't open PDF document!\n"); return;
    }
    // Create the operator table with the needed callbacks.
    table = createMyOperatorTable();
    if(!table){
		CGPDFDocumentRelease(pdfDoc);
		fprintf(stderr, "Couldn't create operator table\n!"); return;
    }
    // Initialize the count of the images.
    totalImages = 0;

    // Obtain the total number of pages for the document.
    totPages = CGPDFDocumentGetNumberOfPages(pdfDoc);

    // Loop over all the pages in the document, scanning the
    // content stream of each one.
    for(i = 1; i <= totPages; i++){
		CGPDFScannerRef scanner = NULL;
		// Get the PDF page for this page in the document.
		CGPDFPageRef p = CGPDFDocumentGetPage(pdfDoc, i);
		// Create a reference to the content stream for this page.
		CGPDFContentStreamRef cs = CGPDFContentStreamCreateWithPage(p);
		if(!cs){
			CGPDFOperatorTableRelease(table);
			CGPDFDocumentRelease(pdfDoc);
			fprintf(stderr, 
			"Couldn't create content stream for page #%zd!\n", i);
			return;
		}
		// Create a scanner for this PDF document page.
		scanner = CGPDFScannerCreate(cs, table, &myData);
		if(!scanner){
			CGPDFContentStreamRelease(cs);
			CGPDFOperatorTableRelease(table);
			CGPDFDocumentRelease(pdfDoc);
			fprintf(stderr, "Couldn't create scanner for page #%zd!\n", i);
			return;
		}
		// Initialize the counters of images for this page.
		myData.numImagesWithColorThisPage = 0;
		myData.numImageMasksThisPage =  0;
		myData.numImagesMaskedWithMaskThisPage =  0;
		myData.numImagesMaskedWithColorsThisPage = 0;
	
		/* 	CGPDFScannerScan causes Quartz to scan the content stream,
			calling the callbacks in the table when the corresponding
			operator is encountered. Once the content stream for the
			page has been consumed or Quartz detects a malformed 
			content stream, CGPDFScannerScan returns. 
		*/
		if(!CGPDFScannerScan(scanner)){
			fprintf(stderr, "Scanner couldn't scan all of page #%zd!\n", i);
		}
		// Print the results for this page.
		printPageResults(outFile, myData, i);
		
		// Update the total count of images with the count of the
		// images on this page.
		totalImages += 
			myData.numImagesWithColorThisPage + 
			myData.numImageMasksThisPage +
			myData.numImagesMaskedWithMaskThisPage +
			myData.numImagesMaskedWithColorsThisPage;
	
		// Once the page has been scanned, release the 
		// scanner for this page.
		CGPDFScannerRelease(scanner);
		// Release the content stream for this page.
		CGPDFContentStreamRelease(cs);
		// Done with this page; loop to next page.
    }
    printDocResults(outFile, totPages, totalImages);

    // Release the operator table this code created.
    CGPDFOperatorTableRelease(table);
    // Release the input PDF CGPDFDocumentRef.
    CGPDFDocumentRelease(pdfDoc);
}

int main (int argc, const char * argv[]) {
    const char *inputFileName = NULL;
    char *outputFileName = NULL;
    CFURLRef inURL = NULL;
    
    if(argc != 2){
		fprintf(stderr, "Usage: %s [inputfile] \n", argv[0]);
        return 1;
    }

    inputFileName = argv[1];
    fprintf(stdout, "Beginning Document \"%s\"\n", inputFileName);

    inURL = CFURLCreateFromFileSystemRepresentation(NULL, inputFileName, 
				strlen(inputFileName), false);
    if(!inURL){
		fprintf(stderr, "Couldn't create URL for input file!\n");
		return 1;
    }
    
    dumpPageStreams(inURL, stdout);
    
    CFRelease(inURL);
    
    return 0;
}
