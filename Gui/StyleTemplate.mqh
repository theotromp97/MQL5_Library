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
class Font
  {
public:
   int               size;
   string            font;
   color             textColor;
   bool              bold;
                     Font()
     {
      size = 15;
      font = "Wingdings";
      textColor = clrBlack;
      bold = false;
     }
                     Font(int _size,    string _font, color _textColor, bool _bold)
     {
      size = _size;
      font = _font;
      textColor = _textColor;
      bold = _bold;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StyleTemplate
  {
public:
   string            objectType;
   string            textFont;
   string            textColor;
   string            bgColor;
   string            lineThickness;
   string            lineColor;
   string            padding;
   Font              font;
                     StyleTemplate()
     {
      objectType = "general";
      bgColor = "gray";
      lineThickness = "1";
      lineColor = "black";
      padding = "";
     }


                     StyleTemplate(string _objectType, string _textFont, string _textColor, string _bgColor, string _lineThickness, string _lineColor, string _padding)
     {
      objectType = _objectType;
      textFont = _textFont;
      textColor = _textColor;
      bgColor = _bgColor;
      lineThickness = lineThickness;
      lineColor = _lineColor;
      padding = _padding;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//Button btn = new Button("btn", 10, 10, 30, 30);

//+------------------------------------------------------------------+
Font defaultFont();
StyleTemplate defaultStyle();
//+------------------------------------------------------------------+
