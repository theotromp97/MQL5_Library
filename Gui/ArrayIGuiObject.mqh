//+------------------------------------------------------------------+
//|                                                StyleTemplate.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <MQL5_Library\Gui\Interfaces\iGuiObject.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ArrayIGuiObject
  {
public:
   iGuiObject        *items[];
   int               count;
                     ArrayIGuiObject()
     { count = 0;}
   bool              Add(iGuiObject *obj)
     {
      int size = ArraySize(items);
      if(ArrayResize(items, size + 1) == -1)
         return false;

      items[size] = obj;
      count++;
      return true;
     }
   int               Count() { return count; }

   iGuiObject        *Get(int index)
     {
      if(index < 0 || index >= count)
         return NULL;
      return items[index];
     }
     
   void              Clear()
     {
      ArrayFree(items);
      count = 0;
     }
  };
//+------------------------------------------------------------------+
