//+------------------------------------------------------------------+
//|                                                 TradeClasses.mqh |
//|                                                             Theo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Theo"
#property link      "https://www.mql5.com"
#property version   "1.00"

enum TradeStatus
  {
   Status_None,
   Status_Open,
   Status_Filled,
   Status_Closed,
   Status_Cancelled
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


enum TradeDirection
  {
   DirectionLong,
   DirectionShort,
  };



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Exit
  {
private:



public:
   ulong             ticket;
   double            volume;
   double            price;
   double            profit;
   long              positionID;
                     Exit()
     {
      // Determine ticketID
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
                     Exit(ulong _ticket)
     {
      ticket = _ticket;
      HistoryDealSelect(ticket);
      price = HistoryDealGetDouble(ticket, DEAL_PRICE);
      volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      positionID = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      // direction
      profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Entry
  {
private:



public:
   double            volume;
   double            price;
   long              positionID;
                     Entry() {}
                     Entry(double _volume, double _price)
     {
      volume = _volume;
      price = _price;
     }
   void              SetPositionID(long _positionID)
     {
      positionID = _positionID;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
