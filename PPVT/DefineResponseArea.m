% Returns a matrix of edges and a matrix of colors for a response area 
% containing 'BOXES' number of BOXES, each with a width of 'BOX_WIDTH'
% pixels, with a border of 'BOX_PADDING' pixels.  The top of the response 
% area is at 'TOP_EDGE'
function DefineResponseArea
% declare globals
global RESPONSE_BACKGROUND % color of response area background
global RESPONSE_EMPTY_COLOR % color for unselected box
global BOXES % the number BOXES in the Likert response
global BOX_WIDTH % the width (and height) of the response BOXES (px)
global BOX_PADDING % the padding for the BOXES (px)
global BOX_CENTERS % 2 x BOXES matrix of the top-left center of each box
% 4 x BOXES matrix of left, top, right, and bottom edges of response area boxes
global BOXES_RECT 
% 3 x BOXES matrix of r, g, b values for background and box in response
% area
global BOXES_COLOR

% initialize BOXES_RECT and BOXES_COLOR
BOXES_RECT = ones(4,BOXES*2); % hold the left, top, right and bottom edges
BOXES_COLOR = ones(3,BOXES*2); % hold the [r g b] colors for each rect in BOXESRect

% build matrix based on locations of intended boxes

% inv: BOX_CENTERS 1..i have had their left, right, top, and bottom edges
% calculated (for both the border and the response box), and had these
% values stored in:
%       BOXES_RECT(:,i) (border) 
%       BOXES_RECT(:,i+BOXES) (resp)
for i=1:length(BOX_CENTERS)
    Left = BOX_CENTERS(1,i) - round(BOX_WIDTH/2) - BOX_PADDING;
    Right = BOX_CENTERS(1,i) + round(BOX_WIDTH/2) + BOX_PADDING;
    Top = BOX_CENTERS(2,i) - round(BOX_WIDTH/2) - BOX_PADDING;
    Bottom = BOX_CENTERS(2,i) + round(BOX_WIDTH/2) + BOX_PADDING;
    
    BOXES_RECT(:,i) = [Left Top Right Bottom]';
    BOXES_COLOR(:,i) = RESPONSE_BACKGROUND';
    BOXES_RECT(:,i+BOXES) = [
        Left + BOX_PADDING % shift left edge right to account for border
        Top + BOX_PADDING % shift top edge down to account for border
        Right - BOX_PADDING % shift right edge left to account for border
        Bottom - BOX_PADDING % shift bottom up up to account for border
        ];
    BOXES_COLOR(:,i+BOXES) = RESPONSE_EMPTY_COLOR';
end