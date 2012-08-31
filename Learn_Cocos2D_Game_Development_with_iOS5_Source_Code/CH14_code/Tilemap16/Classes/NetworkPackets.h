/*
 *  NetworkPackets.h
 *  Tilemap
 *
 *  Created by Steffen Itterheim on 22.01.11.
 */

// TM16: note that all changes made to this send/receive example are prefixed with a // TM16: comment, to make the changes easier to find.

// Defines individual types of messages that can be sent over the network. One type per packet.
typedef enum
{
	kPacketTypeScore = 1,
	kPacketTypePosition,
} EPacketTypes;

// Note: EPacketType type; must always be the first entry of every Packet struct
// The receiver will first assume the received data to be of type SBasePacket, so it can identify the actual packet by type.
typedef struct
{
	EPacketTypes type;
} SBasePacket;

// the packet for transmitting a score variable
typedef struct
{
	EPacketTypes type;
	
	int score;
} SScorePacket;

// packet to transmit a position
typedef struct
{
	EPacketTypes type;
	
	CGPoint position;
} SPositionPacket;


// TODO for you: add more packets as needed. 

/*
 Note that Packets can contain several variables at once. So if you have a bunch of variables
 that you always send out together, put them in a single packet.
 
 But generally try to only send data when you really need to send it, to conserve bandwidth.
 For example, the position information in this example is only sent when the player position actually changed.
*/