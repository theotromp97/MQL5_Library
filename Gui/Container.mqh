//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL5_Library\Gui\GuiObject.mqh>
#include <MQL5_Library\Gui\Rectangle.mqh>
#include <MQL5_Library\Gui\Button.mqh>
#include <MQL5_Library\Gui\ArrayIGuiObject.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Container : public iGuiObject
  {
private:
   ArrayIGuiObject   childArray;
   int               headerHeight;
   int               collapseButtonSize;
   int               Margins;

public:
   string            name;
   int               x, y, width, height;
   bool              created, visible, collapsed;


   Rectangle         rectHeader;
   Label             lblTitle;
   Button            btnCollapse;
   Rectangle         rectBody;

                     Container() {}
                     Container(string _name, int _x, int _y, int _width, int _height, string _title)
     {
      headerHeight = 25;
      collapseButtonSize = 25;
      Margins = 5;

      name = _name;
      x = _x;
      y = _y;
      width = _width;
      height = _height;
      created = false;
      visible = false;
      collapsed = false;

      rectHeader = Rectangle(name + "_rect_header", x, y, width, headerHeight);
      lblTitle   = Label(name + "_lbl_title", x + Margins, y, width - collapseButtonSize - Margins, headerHeight, _title);
      btnCollapse = Button(name + "_btn_toggle", x + width - collapseButtonSize, y, collapseButtonSize, collapseButtonSize, "-");
      rectBody   = Rectangle(name + "_rect_body", x, y + headerHeight, width, height - headerHeight);

      childArray.Add(&rectBody);
     }

   bool              Create() override
     {
      if(created)
         return true;
      if(!rectHeader.Create())
         return false;
      if(!lblTitle.Create())
         return false;
      if(!btnCollapse.Create())
         return false;

      // Create Children
      for(int _i = 0; _i < childArray.count; _i++)
        {
         iGuiObject *child = (iGuiObject *)childArray.Get(_i);
         if(child != NULL)
           {
            if(!child.Create())
               return false;
           }
        }
      created = true;
      return true;
     }

   bool              Delete()
     {
      rectHeader.Delete();
      lblTitle.Delete();
      btnCollapse.Delete();

      for(int _i = 0; _i < childArray.count; _i++)
        {
         iGuiObject *child = (iGuiObject *)childArray.Get(_i);
         if(child != NULL)
           {
            if(!child.Delete())
               return false;
           }
        }

      created = false;
      return true;
     }

   bool              Show()
     {
      if(!Delete())
         return false;
      if(!Create())
         return false;
      return true;
     }

   bool              Hide()
     {
      return Delete();
     }

   bool              ApplyObjectStyle()
     {
      rectHeader.ApplyObjectStyle();
      lblTitle.ApplyObjectStyle();
      btnCollapse.ApplyObjectStyle();

      for(int _i = 0; _i < childArray.count; _i++)
        {
         iGuiObject *child = (iGuiObject *)childArray.Get(_i);
         if(child != NULL)
           {
            if(!child.ApplyObjectStyle())
               return false;
           }
        }

      return true;
     }

   bool              Move(int _relX, int _relY)
     {
      rectHeader.Move(_relX, _relY);
      lblTitle.Move(_relX, _relY);
      btnCollapse.Move(_relX, _relY);

      for(int _i = 0; _i < childArray.count; _i++)
        {
         iGuiObject *child = (iGuiObject *)childArray.Get(_i);
         if(child != NULL)
           {
            if(!child.Move(_relX, _relY))
               return false;
           }
        }

      return true;
     }

   bool              SetWidth(int _width)
     {
      if(!rectHeader.SetWidth(_width))
         return false;
      if(!rectBody.SetWidth(_width))
         return false;
      if(!lblTitle.SetWidth(width - collapseButtonSize - Margins))
         return false;
      if(!btnCollapse.Move(_width - width, 0))
         return false;
      width = _width;
      return true;
     }

   bool                 SetHeight(int _height)
     {
      if(!rectBody.SetHeight(_height))
         return false;
      height = _height;
      return true;
     }

   bool              ToggleCollapse()
     {
      if(collapsed)
        {
         btnCollapse.SetText("-");
         for(int _i = 0; _i < childArray.count; _i++)
           {
            iGuiObject *child = (iGuiObject *)childArray.Get(_i);
            if(child != NULL)
              {
               if(!child.Show())
                  return false;
              }
           }
        }
      else
        {
         btnCollapse.SetText("+");
         for(int _i = 0; _i < childArray.count; _i++)
           {
            iGuiObject *child = (iGuiObject *)childArray.Get(_i);
            if(child != NULL)
              {
               if(!child.Hide())
                  return false;
              }
           }
        }
      collapsed = !collapsed;
      return true;
     }

   ENUM_OBJECT       GetObjectType()
     {
      return 0;
     }

   bool              SetAbsolutePositionToRelative(int _x, int _y)
     {
      // Delete the object if already created to prevent double creation
      Delete();
      x = x + _x;
      y = y + _y;
      //
      if(!rectHeader.SetAbsolutePositionToRelative(x, y))
         return false;
      if(!rectBody.SetAbsolutePositionToRelative(x,y))
         return false;
      if(!lblTitle.SetAbsolutePositionToRelative(x,y))
         return false;
      if(!btnCollapse.SetAbsolutePositionToRelative(x,y))
         return false;
      // Set relative position for all children
      for(int _i = 0; _i < childArray.count; _i++)
        {
         iGuiObject *child = (iGuiObject *)childArray.Get(_i);
         if(child != NULL)
           {
            if(!child.SetAbsolutePositionToRelative(x, y))
               return false;
           }
        }
      return true;
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool              AddGuiObject(iGuiObject &_child)
     {
      _child.SetAbsolutePositionToRelative(x, y + headerHeight);
      if(!_child.Create())
         return false;
      if(childArray.Add(&_child))
         return false;
      return true;
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   int               IsClicked()
     {
      if(btnCollapse.IsClicked(true))
        {
         ToggleCollapse();
         return BTN_RetVal_None;
        }
      else
        {
         // Loop through children
         for(int _i = 0; _i < childArray.count; _i++)
           {
            iGuiObject *child = (iGuiObject*)childArray.Get(_i);
            Button *button = dynamic_cast<Button*>(child);
            if(button != NULL)
              {
               return button.IsClickedRetVal();
              }
           }
        }
      return BTN_RetVal_None;
     }

  };
//+------------------------------------------------------------------+
