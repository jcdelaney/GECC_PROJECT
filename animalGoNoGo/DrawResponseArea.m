% Returns a matrix of edges and a matrix of colors for a response area 
% containing 'BOXES' number of BOXES, each with a width of 'BOX_WIDTH'
% pixels, separated by 'BOX_PADDING' pixels, both from each other and the 
% top and bottom of the response area.  The top of the response area is 
% at 'TOP_EDGE'
function DrawResponseArea
% declare globals
global WINDOW_RECT
global RESPONSE_BACKGROUND % color of response area background
global RESPONSE_EMPTY_COLOR % color for unselected box
global BOXES % the number BOXES in the Likert response
global BOX_WIDTH % the width (and height) of the response BOXES (px)
global BOX_PADDING % the padding for the BOXES (px)
global TOP_EDGE % the location of the top edge of the response area
% 4 x BOXES matrix of left, top, right, and bottom edges of response area boxes
global BOXES_RECT 
% 3 x BOXES matrix of r, g, b values for background and box in response
% area
global BOXES_COLOR


if isempty(WINDOW_RECT)
    WINDOW_RECT = [0 0 1024 768];
end

% calculate the length of the Response area, based on the width of BOXES and the desired padding
ResponseAreaLength = BOX_PADDING + (BOX_WIDTH * BOXES) + (BOX_PADDING * BOXES);
% find the center of the screen, and calculate the left and right edge of the Response area
ScreenCenter = WINDOW_RECT(3)/2;
LeftEdge = ScreenCenter - round(ResponseAreaLength / 2);
% calculate the height of the Response area
ResponseAreaHeight = BOX_PADDING + BOX_WIDTH + BOX_PADDING;
% calculate the top edge of the Response BOXES (not the Response area!)
BoxTOP_EDGE = TOP_EDGE + BOX_PADDING;

% calculate the left, top, right, and bottom edges of the response area
ResponseAreaRect = [ LeftEdge
	TOP_EDGE
	LeftEdge + ResponseAreaLength
	TOP_EDGE + ResponseAreaHeight ];

BOXES_RECT = ones(4,BOXES+1); % hold the left, top, right and bottom edges
BOXES_COLOR = ones(3,BOXES+1); % hold the [r g b] colors for each rect in BOXESRect
% store response area parameters
BOXES_RECT(:,1) = ResponseAreaRect;
BOXES_COLOR(:,1) = RESPONSE_BACKGROUND';

% calculate the left edge of the first response box
BoxLeftEdge = LeftEdge + BOX_PADDING;

% inv: BOXES 1..b have had L, T, R, B added to BOXESRect(:,b)
%+and corresponding BOXESColor have been created
for b=1:BOXES
	BOXES_RECT(:,b+1) = [ BoxLeftEdge
		BoxTOP_EDGE
		BoxLeftEdge + BOX_WIDTH
		BoxTOP_EDGE + BOX_WIDTH];
		% update BoxLeftEdge
		BoxLeftEdge = BoxLeftEdge + BOX_WIDTH + BOX_PADDING;
	BOXES_COLOR(:,b+1) = RESPONSE_EMPTY_COLOR';
end

end