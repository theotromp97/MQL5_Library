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
class Input : public GuiTextObject
  {
public:
                     Input();
                     Input(string _name, int _x, int _y, int _width, int _height, string _text) :
                     GuiTextObject(_name, _x, _y, _width, _height, _text, OBJ_EDIT)
     {
      objectStyle = objectDefaultWhite;
      textStyle = textDefaultBlack;

     }
   bool              Create() override
     {
      //         Print("Failed to create the button! Error code = ",GetLastError());
      //
      if(!ObjectCreate(0, name, objectType, 0, 0, 0))
         return(false);
      if(!ObjectSetString(0, name, OBJPROP_TEXT, text))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_XSIZE, width))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_YSIZE, height))
         return false;
      if(!ObjectSetInteger(0, name, OBJPROP_BACK, false))
         return false;

      // Apply styles
      if(!textStyle.Apply(name))
         return false;
      if(!objectStyle.Apply(name))
         return false;

      visible = true;
      created = true;
      return true;
     }
   string            GetText()
     {
      return            text;
     }
  };
//+------------------------------------------------------------------+
