//+------------------------------------------------------------------+
//|                                                StyleTemplate.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ObjectStyle
  {
public:
   //string            objectType;
   color             bgColor;
   int               lineThickness;
   color             lineColor;
   ENUM_LINE_STYLE   lineStyle;
                     ObjectStyle()
     {
      bgColor = clrGray;
      lineThickness = 1;
      lineColor = clrBlack;
      lineStyle = STYLE_SOLID;
     }
                     ObjectStyle(color _bgColor, int _lineThickness = 1, color _lineColor = clrBlack)
     {
      bgColor = _bgColor;
      lineThickness = lineThickness;
      lineColor = _lineColor;
      lineStyle = STYLE_SOLID;
     }

   bool              Apply(string objectName)
     {
      if(!ObjectSetInteger(0, objectName, OBJPROP_BGCOLOR, bgColor))
         return false;
      if(!ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineThickness))
         return false;
      if(!ObjectSetInteger(0, objectName, OBJPROP_BORDER_COLOR, lineColor))
         return false;
      if(!ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle))
         return false;
      return true;
     }

   bool              SetLineStyle(string objectName, ENUM_LINE_STYLE _lineStyle)
     {
      lineStyle = _lineStyle;
      if(!ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle))
         return false;
      return true;
     }
     
   bool              SetBgColor(string objectName, color _bgColor)
     {
      bgColor = _bgColor;
      if(!ObjectSetInteger(0, objectName, OBJPROP_BGCOLOR, bgColor))
         return false;
      return true;
     }
   bool              SetLineThickness(string objectName, int _lineThickness)
     {
      lineThickness = lineThickness;
      if(!ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineThickness))
         return false;
      return true;
     }
   bool              SetLineColor(string objectName, color _lineColor)
     {
      lineColor = _lineColor;
      if(!ObjectSetInteger(0, objectName, OBJPROP_BORDER_COLOR, lineColor))
         return false;
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ObjectStyle objectDefaultGray();
ObjectStyle objectDefaultDarkGray(clrDarkGray, 1, clrBlack);
ObjectStyle objectDefaultWhite(clrWhite, 1, clrBlack);
//+------------------------------------------------------------------+
