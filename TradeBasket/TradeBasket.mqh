//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <MQL5_Library\Trade\Trade.mqh>
#include <MQL5_Library\TradeBasket\TradeBasketClasses.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradeBasket
  {
private:
   CTrade            tradeManager;
   Trade             tradeArray[];
   TradeDirection    direction;
   TradeBasketStatus status;
   TradeBasketStatus lastStatus;
   void              Init();
   void              UpdateStatus();

public:
                     TradeBasket(CTrade &_tradeManager)
     {
      tradeManager = _tradeManager;
     }
                     TradeBasket() {Init();}

   bool              IsLong() { return direction == DirectionLong; }
   bool              IsShort() { return direction == DirectionShort; }

   bool              IsNone() { return status == BasketStatus_None; }
   bool              IsPartialFilled() { return status == BasketStatus_PartialFilled; }
   bool              IsFilled() { return status == BasketStatus_Filled; }
   bool              IsCancelled() { return status == BasketStatus_Cancelled; }
   bool              IsOpened() { return status == BasketStatus_Open; }
   bool              IsClosed() { return status == BasketStatus_Closed; }

   bool              IsPartialFilledOS() { return status == BasketStatus_PartialFilled && lastStatus != status; }
   bool              IsFilledOS() { return status == BasketStatus_Filled && lastStatus != status; }
   bool              IsCancelledOS() { return status == BasketStatus_Cancelled && lastStatus != status; }
   bool              IsOpenedOS() { return status == BasketStatus_Open && lastStatus != status; }
   bool              IsClosedOS() { return status == BasketStatus_Closed && lastStatus != status; }

   int               GetTotalTrades() {return ArraySize(tradeArray);}
   int               GetTradeCountByStatus(TradeStatus status);
   double            GetTotalVolume();
   double            GetTotalVolumeFilled();
   double            GetAverageEntry();

   bool              AddTrade(Trade &t)
     {
      // TODO error handling
      // add trade to basket
      AddArray(tradeArray, t);
      return true;
     }

   bool              RemoveTrade(Trade &t)
     {
      // find and remove trade
      for(int i = 0; i < ArraySize(tradeArray); i++)
        {
         if(tradeArray[i].ticketID == t.ticketID)
           {
            ArrayRemove(tradeArray, i, 1);
            return true;
           }
        }
      return false;
     }

   void              Update()
     {
      // Update all trades in list
      for(int i = 0; i < ArraySize(tradeArray); i++)
        {
         tradeArray[i].Update();
        }
      UpdateStatus();
     }

   // TODO change to bool
   void              setTakeProfit(double _takeProfitAbs)
     {
      for(int i = 0; i < ArraySize(tradeArray); i++)
        {
         tradeArray[i].SetTakeProfitAbs(_takeProfitAbs);
        }
     }
   bool              CancelOpenTrades()
     {
      for(int i = 0; i < ArraySize(tradeArray); i++)
        {
         if(tradeArray[i].IsOpened())
           {
            if(!tradeArray[i].Cancel())
              {
               return false;
              }
           }
        }
      return true;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeBasket::UpdateStatus()
  {
   int open = 0, filled = 0, closed = 0, cancelled = 0;

   for(int i = 0; i < ArraySize(tradeArray); i++)
     {
      switch(tradeArray[i].status)
        {
         case Status_Open:
            open++;
            break;
         case Status_Filled:
            filled++;
            break;
         case Status_Closed:
            closed++;
            break;
         case Status_Cancelled:
            cancelled++;
            break;
        }
     }

   if(open > 0)
      status = BasketStatus_Open;                           // At least one opened

   if(filled > 0 && filled < ArraySize(tradeArray))
      status = BasketStatus_PartialFilled;                  // At least one and not all filled

   if(filled == ArraySize(tradeArray))
      status = BasketStatus_Filled;                         // All Filled

   if(closed > 0)
     {
      if(CancelOpenTrades())
         status = BasketStatus_Closed;
     }

   if(cancelled == ArraySize(tradeArray))
      status = BasketStatus_Cancelled;                      // All Cancelled

   if(open + filled + closed + cancelled == 0)
      status = BasketStatus_None;                           // No other status
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TradeBasket::GetTotalVolume()
  {
   double totalVolume = 0;

   for(int i = 0; i < ArraySize(tradeArray); i++)
     {
      Trade trade = tradeArray[i];
      totalVolume += trade.totalVolume;
     }

   return totalVolume;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TradeBasket::GetTotalVolumeFilled()
  {
   double totalVolume = 0;

   for(int i = 0; i < ArraySize(tradeArray); i++)
     {
      Trade trade = tradeArray[i];
      if(trade.status == Status_Filled)

        {
         totalVolume += trade.totalVolume;
        }
     }

   return totalVolume;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TradeBasket::GetAverageEntry()
  {
   double totalEntry = 0;
   double totalVolume = 0;

   for(int i = 0; i < ArraySize(tradeArray); i++)
     {
      Trade trade = tradeArray[i];
      totalEntry += trade.averageEntry * trade.totalVolume;
      totalVolume += trade.totalVolume;
     }

   return totalEntry / totalVolume;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradeBasket::GetTradeCountByStatus(TradeStatus status)
  {
   int count = 0;
   for(int i = 0; i < ArraySize(tradeArray); i++)
      if(tradeArray[i].status == status)
         count++;
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeBasket::Init()
  {
   status = BasketStatus_None;
  }
//+------------------------------------------------------------------+
