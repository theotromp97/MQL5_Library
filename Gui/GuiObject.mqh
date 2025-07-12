//+------------------------------------------------------------------+
//|                                                    GuiObject.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <MQL5_Library\Gui\Interfaces\iGuiObject.mqh>
#include <MQL5_Library\Gui\ObjectStyle.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GuiObject : public iGuiObject
  {
public:
   string            name;
   int               x, y, width, height;
   bool              created, visible;
   ENUM_OBJECT       objectType;
   ObjectStyle       objectStyle;
                     GuiObject() {}
                     GuiObject(string _name, int _x, int _y, int _width, int _height, ENUM_OBJECT _objectType)
     {
      name = _name;
      x = _x;
      y = _y;
      width = _width;
      height = _height;
      objectType = _objectType;
      objectStyle = objectDefaultGray;
      created = false;
      visible = false;
     }


   virtual bool              Create()
     {
      return false;
     }

   bool              Delete()
     {
      if(created)
        {
         if(!ObjectDelete(0, name))
            return false;
        }
      created = false;
      return true;
     }

   void              SetObjectStyle(ObjectStyle &_objectStyle)
     {
      objectStyle = _objectStyle;
     }

   bool              Show()
     {
      return Create();
      if(created)
         return true;
     }

   bool              Hide()
     {
      if(!created)
         return true;
      if(!ObjectDelete(0, name))
        {
         Print(StringFormat("Cannot hide/Delete %s.", name));
         return false;
        }

      created = false;
      return true ;
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool              ApplyObjectStyle()
     {
      if(!created)
         return false;
      return objectStyle.Apply(name);
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool              Move(int _relX, int _relY)
     {
      if(!created)
         return false;

      if(!ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + _relX))
         return false;
      if(! ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y + _relY))
         return false;
      x = x + _relX;
      y = y + _relY;
      return true;
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool                 SetWidth(int _width)
     {
      if(!created)
         return false;

      if(!ObjectSetInteger(0, name, OBJPROP_XSIZE, _width))
         return false;
      width = _width;
      return true;
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool              SetHeight(int _height)
     {
      if(!created)
         return false;

      if(!ObjectSetInteger(0, name, OBJPROP_YSIZE, _height))
         return false;
      height = height;
      return true;
     }

  };


//+------------------------------------------------------------------+
