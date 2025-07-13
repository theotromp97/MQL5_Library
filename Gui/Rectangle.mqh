//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL5_Library\Gui\GuiTextObject.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Rectangle : public GuiObject
  {
public:
                     Rectangle(){}
                     Rectangle(string _name, int _x, int _y, int _width, int _height) :
                     GuiObject(_name, _x, _y, _width, _height, OBJ_RECTANGLE_LABEL)
     {
     objectStyle = objectDefaultGray;
     }
   bool              Create() override
      {  
      if(created)
         return true;
//         Print("Failed to create the button! Error code = ",GetLastError());
      if(!ObjectCreate(0, name, objectType, 0, 0, 0))
         return(false);
      if(!ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_XSIZE, width))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_YSIZE, height))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_FILL,true))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_ZORDER,-1))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_STYLE,STYLE_SOLID))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT))
         return false;
      // Apply styles
      if(!objectStyle.Apply(name))
         return false;
    
      visible = true;
      created = true;
      return true;
     }

  };