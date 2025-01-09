//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                                             Theo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Theo"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <MQL5_Library\Trade\TradeClasses.mqh>
#include <MQL5_Library\HelpFunctions.mqh>
class Trade
  {
private:
   CTrade            tradeManager;
   TradeStatus       lastStatus;

   void              Init();

   void              AddExit();
   void              AddEntry();
   void              UpdateStatus();
   void              CalculatePNL();

   void              SetLimit(double _volume, double _entry);
   void              SetMarket(double _volume);

public:
   string            symbol;
   TradeDirection    direction;
   TradeStatus       status;

   ulong             ticketID;
   double            totalVolume;
   double            averageEntry;
   double            takeProfit;
   double            stopLoss;
   double            realizedPNL;
   double            unrealizedPNL;
   double            totalPNL;
   Exit              exits[];
   Entry             entries[];


   bool              IsLong() { return direction == DirectionLong;}
   bool              IsShort() { return direction == DirectionShort;}

   bool              IsFilled() {return status == Status_Filled;}
   bool              IsCancelled() {return status == Status_Cancelled;}
   bool              IsOpened() {return status == Status_Open;}
   bool              IsClosed() {return status == Status_Closed;}

   bool              IsFilledOS() {return status == Status_Filled && lastStatus != status;}
   bool              IsCancelledOS() {return status == Status_Cancelled && lastStatus != status;}
   bool              IsOpenedOS() {return status == Status_Open && lastStatus != status;}
   bool              IsClosedOS() {return status == Status_Closed && lastStatus != status;}



   void              SetStopOrder(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0);
   void              SetTakeProfitAbs(double absTakeProfit);
   void              SetTakeProfitRel(double relTakeProfit);
   void              SetStopLossAbs(double absStopLoss);
   void              SetStopLossRel(double relStopLoss);
   void              Close();

                     Trade() {Init();}
                     Trade(CTrade& _tradeManager)
     {
      Init();
      status = Status_None;
      tradeManager = _tradeManager;
     };

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void              Enter(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0)
     {
      symbol = _symbol;
      direction = _direction;

      stopLoss = _stopLoss;
      takeProfit = _takeProfit;

      // Determine Bid / Ask price
      // Open new limit if price is below / above bid / ask
      double _currentPrice = 0.0;
      if(IsLong())
        {
         _currentPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
         if(_currentPrice <= _entry)
            SetMarket(NormalizeDouble(_volume, 2));
         else
            SetLimit(NormalizeDouble(_volume, 2), _entry);
        }
      else
        {
         _currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
         if(_currentPrice >= _entry)
            SetMarket(NormalizeDouble(_volume, 2));
         else
            SetLimit(NormalizeDouble(_volume, 2), _entry);
        }
     }

   void              Update()
     {
      UpdateStatus();

      // Update Entries
      if(IsFilledOS())
         AddEntry();

      // Update exits
      if(IsClosedOS())
         AddExit();

      CalculatePNL();

      // set old status to trigger one shots
      lastStatus = status;
     }

   void              Trade::Cancel()
     {
      tradeManager.OrderDelete(ticketID);
      status = Status_Cancelled;
     }
  };


//+------------------------------------------------------------------+
void              Trade::SetLimit(double _volume, double _entry)
  {
   if(IsLong())
     {
      if(tradeManager.BuyLimit(_volume, _entry, symbol, stopLoss, takeProfit, ORDER_TIME_GTC,0))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Open;
        }
     }
   else
     {
      if(tradeManager.SellLimit(_volume, _entry, symbol, stopLoss, takeProfit, ORDER_TIME_GTC, 0))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Open;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::SetMarket(double _volume)
  {
   if(IsLong())
     {
      if(tradeManager.Buy(_volume, symbol, 0.0, stopLoss, takeProfit))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Filled;
        }
     }
   else
     {
      if(tradeManager.Sell(_volume, symbol, 0.0, stopLoss, takeProfit))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Filled;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::SetStopOrder(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0)
  {

   symbol = _symbol;
   direction = _direction;
   double entry = _entry;
   double volume = NormalizeDouble(_volume, 2);
   stopLoss = _stopLoss;
   takeProfit = _takeProfit;
   if(IsLong())
     {
      if(tradeManager.BuyStop(volume, entry, symbol, stopLoss, takeProfit, ORDER_TIME_GTC,0))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Open;
        }
     }
   else
     {
      if(tradeManager.SellStop(volume, entry, symbol, stopLoss, takeProfit, ORDER_TIME_GTC, 0))
        {
         ticketID = tradeManager.ResultOrder();
         double tradeVolume =  tradeManager.RequestVolume();
         double tradeEntry = tradeManager.RequestPrice();
         averageEntry = (averageEntry * totalVolume + tradeVolume * tradeEntry) / (totalVolume + tradeVolume);
         totalVolume = totalVolume + tradeVolume;
         status = Status_Open;
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Trade::Close()
  {
   if(tradeManager.PositionClose(ticketID))
     {
      status=Status_Closed;
      CalculatePNL();
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::AddExit()
  {
// get deals
   HistorySelectByPosition(ticketID);
// get information on latest deal
   ulong ticket = HistoryDealGetTicket(HistoryDealsTotal()-1);
   long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
   long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
   if((dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL) &&
      (dealEntry == DEAL_ENTRY_OUT))
     {
      Exit e(ticket);
      AddArray(exits, e);
      //break;
     }
//}
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::AddEntry()
  {
// get deals
   HistorySelectByPosition(ticketID);
// get information on first deal
   ulong ticket = HistoryDealGetTicket(0);
   long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
   long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
   if((dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL) &&
      (dealEntry == DEAL_ENTRY_IN))
     {
      double volume = HistoryDealGetDouble(ticket,DEAL_VOLUME);
      double entry = HistoryDealGetDouble(ticket,DEAL_PRICE);
      Entry e(volume, entry);
      AddArray(entries, e);
      //break;
     }
//}
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::UpdateStatus()
  {
// SetStatus
// status cancelled and opened are set on entry/cancel
   if(PositionSelectByTicket(ticketID))
      status = Status_Filled;
   if(IsFilled() && ! PositionSelectByTicket(ticketID))
      status = Status_Closed;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::CalculatePNL()
  {
// unrealized profit
   if(PositionSelectByTicket(ticketID))
      unrealizedPNL = PositionGetDouble(POSITION_PROFIT);
   else
      unrealizedPNL = 0.0;

// realized profit
   realizedPNL = 0.0;
   for(int i=0;i<ArraySize(exits);i++)
     {
      realizedPNL = realizedPNL + exits[i].profit;
     }
   totalPNL = unrealizedPNL + realizedPNL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::SetTakeProfitAbs(double absTakeProfit)
  {
   if(absTakeProfit == takeProfit)
      return;
   takeProfit = absTakeProfit;
   if(IsFilled())
      tradeManager.PositionModify(ticketID, stopLoss, takeProfit);
   else
      tradeManager.OrderModify(ticketID, averageEntry, stopLoss, takeProfit, ORDER_TIME_GTC, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::SetTakeProfitRel(double relTakeProfit)
  {
   double newTakeProfit = direction == DirectionLong ? averageEntry + relTakeProfit : averageEntry - relTakeProfit;
   if(newTakeProfit == takeProfit)
      return;
   takeProfit = newTakeProfit;
   if(IsFilled())
      tradeManager.PositionModify(ticketID, stopLoss, takeProfit);
   else
      tradeManager.OrderModify(ticketID, averageEntry, stopLoss, takeProfit, ORDER_TIME_GTC, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::SetStopLossAbs(double absStopLoss)
  {
   if(absStopLoss == stopLoss)
      return;
   stopLoss = absStopLoss;
   if(IsFilled())
      tradeManager.PositionModify(ticketID, stopLoss, takeProfit);
   else
      tradeManager.OrderModify(ticketID, averageEntry, stopLoss, takeProfit, ORDER_TIME_GTC, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::SetStopLossRel(double relStopLoss)
  {
   double newStopLoss;
   direction == DirectionLong ? newStopLoss = averageEntry - relStopLoss : newStopLoss = averageEntry + relStopLoss;
   if(newStopLoss == stopLoss)
      return;
   stopLoss = newStopLoss;
   if(IsFilled())
      tradeManager.PositionModify(ticketID, stopLoss, takeProfit);
   else
      tradeManager.OrderModify(ticketID, averageEntry, stopLoss, takeProfit, ORDER_TIME_GTC, 0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::Init(void)
  {
   lastStatus = Status_None;
   symbol = "";
   direction = DirectionLong;
   status = Status_None;

   ticketID = 0;
   totalVolume = 0.0;
   averageEntry = 0.0;
   takeProfit = 0.0;
   stopLoss = 0.0;
   realizedPNL = 0.0;
   unrealizedPNL = 0.0;
   totalPNL = 0.0;
  }
//+------------------------------------------------------------------+
