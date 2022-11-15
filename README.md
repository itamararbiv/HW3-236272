# Android Development (236271) - Assignment 3
## Dry Questions

### Question 1:
What class is used to implement the controller pattern in this library? What features does it allow the developer to control?

### Answer 1:
- The class “SnappingSheetController” implements the controller for the snapping_sheet widget. 
-  The class “SnappingSheetController” allows the developers the features to control the sheet and to get the current snap position.
For example: edit snappings position factor, stop current snapping, set snapping sheet position, and also we can extract information from the sheet, like current position, current snapping position, currently snapping, attached status, etc…

## Using examples:

snappingSheetController.snapToPosition(SnappingPosition.factor(positionFactor: 0.75),);
snappingSheetController.stopCurrentSnapping();
snappingSheetController.setSnappingSheetPosition(100);
snappingSheetController.currentPosition;
snappingSheetController.currentSnappingPosition;
snappingSheetController.currentlySnapping;
snappingSheetController.isAttached;

### Question 2:
The library allows the bottom sheet to snap into position with various different animations. What parameter controls this behavior?

### Answer 2:
Like we have seen before at workshop 3, the parameter that controls various different animation positions is curve, and snappingCurve in particular for snapping_sheet widget. 
This parameter is defined under the SnappingPosition parameter. 
In default, the snappingCurve is set to be Curves.linear. 

## Using examples:

return SnappingSheet(
      child: Background(),
      lock Overflow Drag: true,
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingCurve: Curves.easeOutExpo,
          snappingDuration: Duration(seconds: 1),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),]
);

### Question 3:
Name one advantage of InkWell over the latter and one advantage of GestureDetectorover the first.

### Answer 3:
- GestureDetector class is huge, he can detect every type of interaction the user has with the screen or widget by using this class
(it includes pinch, swipe, touch, plus custom gestures).
- InkWell dont have alot of gestures to detect (like GestureDetector have) but on the other hand,  it gives you a lot of ways to decorate the widget like including a ripple effect tap (that GestureDetector doesn't support). 
For example: you can decorate colors: splashColor, focusColor, hoverColor and also decorate borders: borderRadius, customBorder.
Using examples:

## Using examples:

### InkWell:
InkWell( onTap: () {}, child: Ink( width: 200, height: 200, color: Colors.blue, ), )

### GestureDetector:
GestureDetector(onTap: () {setState(() {
_lightIsOn = !_lightIsOn;});},
 child: Container(
color: Colors.yellow.shade600,
 padding: const EdgeInsets.all(8),),),




