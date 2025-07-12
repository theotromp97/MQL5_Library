//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL5_Library\Gui\GuiTextObject.mqh>

#define BTN_STATE_Clicked 1
#define BTN_STATE_NotClicked 0
#define BUTTON_RETVAL_NONE 0

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Button : public GuiTextObject
  {
public:
   int               returnCode;
                     Button() {}
                     Button(string _name, int _x, int _y, int _width, int _height, string _text, int _returnCode = 1) :
                     GuiTextObject(_name, _x, _y, _width, _height, _text, OBJ_BUTTON)
     {
      returnCode = _returnCode;
     }

   //+------------------------------------------------------------------+
   bool              Create() override
     {
      if(!ObjectCreate(0, name, objectType, 0, x, y, x+width, y+height))
         return false;
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
      textStyle.Apply(name);
      objectStyle.Apply(name);
      visible = true;
      created = true;
      return true;
     }

   bool              SetButtonState(bool _clicked)
     {
      return ObjectSetInteger(0, name, OBJPROP_STATE, _clicked);
     }
   bool               IsClicked(bool resetButtonState = true)
     {
      long retVal = ObjectGetInteger(0, name, OBJPROP_STATE);
      if(resetButtonState)
         ObjectSetInteger(0, name, OBJPROP_STATE, BTN_STATE_NotClicked);
      return retVal == 1;
     }
   //+------------------------------------------------------------------+
   int               IsClickedRetVal()
     {
      if(IsClicked())
        {
         return returnCode;
        }
      else
        {
         return BUTTON_RETVAL_NONE;
        }
     }
  };
//+------------------------------------------------------------------+
