//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL5_Library\Gui\GuiObject.mqh>

struct GridCell
  {
   int               row;
   int               column;
   iGuiObject        *obj;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Grid : public iGuiObject
  {
private:
   GridCell          children[];
   int               totalColumns, totalRows;
   int               cellWidth[];
   int               cellHeight[];
   int               x, y;
   bool              created;
   bool              InitializeLayout();

   int               GetMaxWidth() {return ArrayMaximum(cellWidth, 0);}
   int               GetMaxHeight() {return ArrayMaximum(cellHeight, 0);}



public:
   int               returnCode;
                     Grid() {}
                     Grid(int _x, int _y, int _rows, int _columns)
     {
      x = _x;
      y = _y;
      totalRows = _rows;
      totalColumns = _columns;

      // Set cell height and width
      ArrayResize(cellWidth, totalColumns);
      ArrayInitialize(cellWidth, 0);
      ArrayResize(cellHeight, totalRows);
      ArrayInitialize(cellHeight, 0);
      ArrayResize(children, totalRows * totalColumns);
     }

   bool              AddChild(iGuiObject *child, int row, int column)
     {
      // Check if row and column is correct
      if(row < 0 || row > totalRows - 1 || column < 0 || column > totalColumns - 1)
        {
         printf("wrong row/column number");
         return false;
        }

      // Get cell index
      int index = GetCellIndex(row, column);
      if(index > ArraySize(children))
        {
         printf("wrong children array index");
         return false;
        }

      // Add child to child array
      children[index].row = row;
      children[index].column = column;
      children[index].obj = child;
      return true;
     }

   //+------------------------------------------------------------------+
   bool              Create()
     {
      InitializeLayout();
      created = true;
      for(int i=0;i<ArraySize(children);i++)
        {
         if(children[i].obj != NULL)
           {
            if(!children[i].obj.Create())
              {
               created = false;
               return false;
              }
           }
        }
      return true;
     }

   bool              Delete()
     {
      for(int i=0;i<ArraySize(children);i++)
        {
         if(children[i].obj != NULL)
           {
            if(!children[i].obj.Delete())
               return false;
           }
        }
      return true;
     }

   bool              Show()
     {
      return Create();
     }

   bool              Hide()
     {
      if(!created)
         return true;

      for(int i=0;i<ArraySize(children);i++)
        {
         if(children[i].obj != NULL)
           {
            if(!children[i].obj.Delete())
               return false;
           }
        }

      created = false;
      return true ;
     }
   bool              ApplyObjectStyle()
     {
      for(int i=0;i<ArraySize(children);i++)
        {
         if(children[i].obj != NULL)
           {
            if(!children[i].obj.ApplyObjectStyle())
               return false;
           }
        }
      return true;
     }
   bool              Move(int _relX, int _relY)
     {
      for(int i=0;i<ArraySize(children);i++)
        {
         if(children[i].obj != NULL)
           {
            if(!children[i].obj.Move(_relX, _relY))
               return false;
           }
        }
      return true;
     }
   bool              SetPosition(int _x, int _y)
     {
      x = _x;
      y = _y;
      if(created)
        {
         if(!Delete())
            return false;
         return Create();
        }
      return InitializeLayout();
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void              Update()
     {
      int _retVal = IsClickedRetVal();
     }

   int               IsClickedRetVal()
     {
      for(int i=0;i<ArraySize(children);i++)
        {
         // cast as button
         Button *button = dynamic_cast<Button*>(children[i].obj);
         if(button != NULL)
           {
            int _retVal = button.IsClickedRetVal();
            if(_retVal != BTN_RetVal_None)
               return _retVal;
           }
         else
           {

            Container *container = dynamic_cast<Container*>(children[i].obj);
            if(container != NULL)
              {
               int _retVal = container.IsClicked();
               if(_retVal != BTN_RetVal_None)
                  return _retVal;
              }
           }
        }
      return BTN_RetVal_None;
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   int               GetCellIndex(int _row, int _column)
     {
      return _row * totalColumns + _column;
     }


   bool              SetWidth(int _width) {return false;}
   bool              SetHeight(int _height) {return false;}

   int               GetX()         { return x;       }
   int               GetY()         { return y;       }
   int               GetWidth()     { return 0;   }
   int               GetHeight()    { return 0;  }

   ENUM_OBJECT       GetObjectType() {return 0;}

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              Grid::InitializeLayout()
  {
// This method will rewrite the relative position for each object

   for(int i=0;i<ArraySize(children);i++)
     {
      if(children[i].obj != NULL)
        {
         // Set height for the row
         GridCell cell = children[i];
         int height = cellHeight[cell.row];
         if(cellHeight[children[i].row] < cell.obj.GetHeight())
            cellHeight[children[i].row] = cell.obj.GetHeight();

         // Set width for the column
         if(cellWidth[children[i].column] < cell.obj.GetWidth())
            cellWidth[children[i].column] = cell.obj.GetWidth();
        }
     }
   for(int i=0;i<ArraySize(children);i++)
     {
      if(children[i].obj != NULL)
        {

         // get x position
         int xOffset = x;
         for(int j = 0; j < children[i].column; j++)
            xOffset += cellWidth[j];
         int yOffset = y;
         for(int j = 0; j < children[i].row; j++)
            yOffset += cellHeight[j];

         int positionX = xOffset + (cellWidth[children[i].column] - children[i].obj.GetWidth()) / 2;
         int positionY = yOffset + (cellHeight[children[i].row] - children[i].obj.GetHeight()) / 2;
         children[i].obj.SetPosition(positionX, positionY);
        }

     }
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
