class BaseGui
  {
public:
   bool              CreateRectangle(string name, int x, int y, int width, int height, color bgColor);
   bool              CreateButton(string name, string text, int x, int y,int width, int height, color txtColor, color bgColor);
   bool              CreateInput(string name, int x, int y,int width, int height, string text="");
   bool              CreateText(string name, string text, int x, int y,int width, int height, color textColor, color bgColor=clrNONE, int fontSize=10);
   bool              GetInput(string name, string &text);
   bool              SetText(string name, string text);
   bool              CreateHline(string name, double price, color clr);

   void              ShowButton(string _name, bool _show);

  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseGui::CreateRectangle(string name, int x, int y, int width, int height, color bgColor)
  {
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      Print("Failed to create the button! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_FILL,true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,-1);
   ObjectSetInteger(0, name, OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   return true;
  }
//+------------------------------------------------------------------+
bool BaseGui::CreateButton(string name, string text, int x, int y,int width, int height, color txtColor, color bgColor)
  {
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
     {
      Print("Failed to create the button! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   return true;
  }

//+------------------------------------------------------------------+
bool BaseGui::CreateInput(string name, int x, int y,int width, int height, string text="")
  {
   if(!ObjectCreate(0,name,OBJ_EDIT,0,0,0))
     {
      Print("Failed to create the button! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   return true;
  }

//+------------------------------------------------------------------+
bool BaseGui::CreateText(string name, string text, int x, int y,int width, int height, color textColor, color bgColor=clrNONE, int fontSize=10)
  {
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      Print("Failed to create the button! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   return true;
  }
//+------------------------------------------------------------------+
bool BaseGui::GetInput(string name, string &text)
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectGetString(0,name,OBJPROP_TEXT,0,text))
     {
      Print("failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
bool BaseGui::SetText(string name, string text)
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectSetString(0,name,OBJPROP_TEXT,0,text))
     {
      Print("failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
bool BaseGui::CreateHline(string name, double price, color clr)
  {
   if(!ObjectCreate(0,name,OBJ_HLINE,0,0, price))
     {
      Print("Failed to create the button! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   return true;
  }
//+------------------------------------------------------------------+
void BaseGui::ShowButton(string _name, bool _show)
  {
   bool hidden  = !_show;
   ObjectSetInteger(0, _name, OBJPROP_HIDDEN, hidden);
  }
//+------------------------------------------------------------------+

