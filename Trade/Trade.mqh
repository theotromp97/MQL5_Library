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
#include <MQL5_Library\Gui\Arrow.mqh>


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   bool              SetLimit(double _volume, double _entry);
   bool              SetMarket(double _volume);
   Arrow             arrowArray[];

public:
   string            symbol;
   TradeDirection    direction;
   TradeStatus       status;

   ulong             ticketID;
   double            totalVolume;
   double            averageEntry;
   double            averageExit;
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
   bool              IsNone()   {return status == Status_None;}

   bool              IsFilledOS() {return status == Status_Filled && lastStatus != status;}
   bool              IsCancelledOS() {return status == Status_Cancelled && lastStatus != status;}
   bool              IsOpenedOS() {return status == Status_Open && lastStatus != status;}
   bool              IsClosedOS() {return status == Status_Closed && lastStatus != status;}
   double            GetLastClosePNL(int offset);


   bool              SetStopOrder(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0);
   void              SetTakeProfitAbs(double absTakeProfit);
   void              SetTakeProfitRel(double relTakeProfit);
   void              SetStopLossAbs(double absStopLoss);
   void              SetStopLossRel(double relStopLoss);
   bool              Close();
   bool              ClosePartial(double _volume);

   static TradeDirection   OppositeDirection(TradeDirection dir)
     {
      if(dir == DirectionLong)
         return DirectionShort;
      else
         return DirectionLong;
     }

   double            GetLastExitPrice()
     {
      if(ArraySize(exits) <= 0)
         return 0.0;
      return exits[ArraySize(exits) - 1].price;
     }

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
   bool              Enter(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0)
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
            return SetMarket(NormalizeDouble(_volume, 2));
         else
            return SetLimit(NormalizeDouble(_volume, 2), _entry);
        }
      else
        {
         _currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
         if(_currentPrice >= _entry)
            return SetMarket(NormalizeDouble(_volume, 2));
         else
            return SetLimit(NormalizeDouble(_volume, 2), _entry);
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

   bool              Trade::Cancel()
     {
      if(!tradeManager.OrderDelete(ticketID))
         return false;
      status = Status_Cancelled;
      return true;
     }

   bool              Draw()
     {

      // Check closed oneshot to prevent redrawing of finished trades
      if(IsClosedOS())
        {
         // Delete Old (oneshot)
         for(int i=0;i<ArraySize(arrowArray);i++)
           {
            if(!arrowArray[i].Delete())
               return false;
           }
         // Create new (oneShot)
         for(int i=0; i<ArraySize(entries); i++)
           {
            Arrow a = new Arrow(StringFormat("Entry %s", (string)ticketID), entries[i].time, entries[i].price, exits[0].time, exits[0].price);
            a.Create();
            AddArray(arrowArray, a);
           }
         return true;
        }
      printf((string)status);
      printf((string)Status_Open);
      if(IsFilled())
        {
         // Delete old
         for(int i=0;i<ArraySize(arrowArray);i++)
           {
            if(!IsClosed())
              {
               if(!arrowArray[i].Delete())
                  return false;
               RemoveFromArray(arrowArray, i);

              }
           }
         // Create new
         for(int i=0; i<ArraySize(entries); i++)
           {
            if(IsFilled())
              {
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               Arrow a = new Arrow(StringFormat("Entry %s", (string)ticketID), entries[i].time, entries[i].price, TimeCurrent(),currentPrice);
               a.Create();
               AddArray(arrowArray, a);
              }
           }
        }
      return true;
     }

  };



//+------------------------------------------------------------------+
bool              Trade::SetLimit(double _volume, double _entry)
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
      else
         return false;
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
      else
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trade::SetMarket(double _volume)
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
      else
         return false;
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
      else
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              Trade::SetStopOrder(string _symbol, TradeDirection _direction, double _volume, double _entry, double _takeProfit=0.0, double _stopLoss = 0.0)
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
      else
         if(SetMarket(volume))
            return true;
         else
            return false;
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
      else
         if(SetMarket(volume))
            return true;
         else
            return false;
     }
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool Trade::Close()
  {
   if(tradeManager.PositionClose(ticketID))
     {
      status=Status_Closed;
      CalculatePNL();
     }
   else
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trade::ClosePartial(double _volume)
  {
   if(tradeManager.PositionClosePartial(ticketID, _volume))
     {
      AddExit();
      CalculatePNL();
     }
   else
      return false;
   return true;
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
      totalVolume -= e.volume;
      //break;
     }
   else
     {
      Alert("Exit not found. Code line: Trade.mqh:280");
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
      datetime time = (datetime) HistoryDealGetInteger(ticket, DEAL_TIME);
      Entry e(volume, entry, time);
      AddArray(entries, e);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Trade::UpdateStatus()
  {
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
//|                                                                  |
//+------------------------------------------------------------------+
double Trade::GetLastClosePNL(int offset = 0)
  {
   if(ArraySize(exits) <= 0)
      return 0.0;
   double _profit = exits[ArraySize(exits) - offset - 1].profit;
   return _profit;
  }
//+------------------------------------------------------------------+
