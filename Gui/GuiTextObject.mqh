//+------------------------------------------------------------------+
//|                                                    GuiObject.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


#include <MQL5_Library\Gui\GuiObject.mqh>
#include <MQL5_Library\Gui\TextStyle.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GuiTextObject : public GuiObject
  {
public:
   TextStyle         textStyle;
   string            text;
                     GuiTextObject() {}
                     GuiTextObject(string _name, int _x, int _y, int _width, int _height, string _text, ENUM_OBJECT _objectType) :
                     GuiObject(_name, _x, _y, _width, _height, _objectType)
     {
      text = _text;
      textStyle = textDefaultBlack;
     }
                     GuiTextObject(string _name, datetime _x_start, double _y_start, datetime _x_end, double _y_end, string _text, ENUM_OBJECT _objectType) :
                     GuiObject(_name, _x_start, _y_start, _x_end, _y_end, _objectType)
     {
      text = _text;
      textStyle = textDefaultBlack;
     }

   bool              SetText(string _text)
     {
      if(!created)
         return false;
      if(!ObjectSetString(0, name, OBJPROP_TEXT, _text))
         return false;
      text = _text;
      return true;
     }

   bool              SetTextStyle(TextStyle &_textStyle)
     {
      if(!created)
         return false;
      textStyle = _textStyle;
      return textStyle.Apply(name);
     }
  };
//+------------------------------------------------------------------+
