//+------------------------------------------------------------------+
//|                                                   HedgeTrade.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Theo"
#property link "https://www.mql5.com"
#property version "1.00"

#include <MQL5_Library\Trade\Trade.mqh>
#include <MQL5_Library\Trade\HedgeClasses.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HedgeTrade
  {
private:
   CTrade            tradeManager;
   HedgeStatus       lastStatus;
   bool              _onStateEntry;
   bool              OnStateEntry() {  bool retVal = _onStateEntry; _onStateEntry = false; return retVal;}

   double            _collectedProfit;
   void              Init();
   void              OpenHedge();;
   void              TransitionToState(HedgeStatus newStatus);
   void              UpdateStatus();
   void              UpdateStatus2();
   void              CalculatePnl();

public:
   string            symbol;
   TradeDirection    initialDirection;
   HedgeStatus       status;

   double            initialHedgeDistance;
   double            initialProfitDistance;
   double            initialEntry;
   double            initialHedgeEntry;
   double            hedgeDistance;
   double            profitDistance;

   bool              IsPending() { return status == HedgeStatus_Open; }
   bool              IsFilled() { return status == HedgeStatus_Filled; }
   bool              IsHedged() { return status == HedgeStatus_Hedged; }
   bool              IsClosed() { return status == HedgeStatus_Closed; }

   bool              IsPendingOS() { return status == HedgeStatus_Open && lastStatus != status; }
   bool              IsFilledOS() { return status == HedgeStatus_Filled && lastStatus != status; }
   bool              IsHedgedOS() { return status == HedgeStatus_Hedged && lastStatus != status; }
   bool              IsClosedOS() { return status == HedgeStatus_Closed && lastStatus != status; }

   void              SetHedgeDistance(double distance);
   void              ResetHedgeDistance();

   void              SetProfitDistance(double distance);
   void              ResetProfitDistance();

   Trade             initialTrade;
   Trade             hedgeTrade;

   double            realizedPNL;
   double            unrealizedPNL;
   double            totalPNL;

   double            Volume() {return initialTrade.totalVolume;}

   double            CollectedProfit() { return _collectedProfit; }

                     HedgeTrade() {}
                     HedgeTrade(CTrade &_tradeManager)
     {
      status = HedgeStatus_None;
      tradeManager = _tradeManager;
      initialTrade = new Trade(tradeManager);
      hedgeTrade = new Trade(tradeManager);
     }

   bool              Open(string _symbol, TradeDirection direction, double volume, double entry, double _profitDistance, double _hedgeDistance);

   void              Update();

   bool              TrimUsingProfit();

   void              BalanceHedge();

   bool              Close();

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeTrade::TrimUsingProfit()
  {
   if(initialTrade.IsFilled() == false && hedgeTrade.IsFilled() == false)
     {
      // cannot be trimmed, no position open
      return false;
     }
   if(initialTrade.IsFilled())
     {
      double profitPerLot = MathAbs(initialTrade.unrealizedPNL / initialTrade.totalVolume);
      double lots = MathFloor(_collectedProfit / profitPerLot * 100) / 100;         // * 100 / 100 to floor on 0.01 lots
      lots = lots > initialTrade.totalVolume ? initialTrade.totalVolume : lots;
      if(lots >= 0.01)
        {
         initialTrade.ClosePartial(lots);
         return true;
        }
     }
   if(hedgeTrade.IsFilled())
     {
      double profitPerLot = MathAbs(hedgeTrade.unrealizedPNL / hedgeTrade.totalVolume);
      double lots = MathFloor(_collectedProfit / profitPerLot * 100) / 100;         // * 100 / 100 to floor on 0.01 lots;
      if(lots >= 0.01)
        {
         initialTrade.ClosePartial(lots);
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::BalanceHedge()
  {
   if(!initialTrade.IsOpened() && !initialTrade.IsFilled())
     {
      double _lastExit = initialTrade.GetLastExitPrice();
      double _entry = initialDirection == DirectionLong ? _lastExit + hedgeDistance : _lastExit - hedgeDistance;
      // Overwrite if trade is initial trade
      if(_lastExit == 0)
         _entry = initialEntry;

      double _volume = hedgeTrade.totalVolume;
      double _tp = initialDirection == DirectionLong ? _entry + profitDistance : _entry - profitDistance;

      initialTrade = new Trade(tradeManager);
      //if(!initialTrade.Enter(symbol, initialDirection, _volume, _entry, _tp, 0.0))
      if(!initialTrade.SetStopOrder(symbol, initialDirection, _volume, _entry, _tp))
         printf("Error in Setting Stop Order");
      return;
     }

   if(!hedgeTrade.IsOpened() && !hedgeTrade.IsFilled())
     {
      TradeDirection _direction = Trade::OppositeDirection(initialDirection);
      double _lastExit = hedgeTrade.GetLastExitPrice();
      double _entry = _direction == DirectionLong ? _lastExit + hedgeDistance : _lastExit - hedgeDistance;

      // Overwrite if trade is initial trade
      if(_lastExit == 0.0)
         _entry = initialHedgeEntry;

      double _volume = initialTrade.totalVolume;
      double _tp = _direction == DirectionLong ? _entry + profitDistance : _entry - profitDistance;
      hedgeTrade = new Trade(tradeManager);
      if(!hedgeTrade.SetStopOrder(symbol, _direction, _volume, _entry, _tp))
         printf("Error in Setting Stop Order");
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::Update()
  {
   UpdateStatus2();
   CalculatePnl();

// open / close hedge
// BalanceHedge();

// Trim the opposing side
   if(IsHedged() && false)
     {
      if((initialTrade.IsClosedOS() && hedgeTrade.IsClosed() == false) || (hedgeTrade.IsClosedOS() && initialTrade.IsClosed() == false))
         TrimUsingProfit();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::UpdateStatus()
  {
// update trades
   initialTrade.Update();
   hedgeTrade.Update();

   lastStatus = status;

// update status
   if(initialTrade.IsClosed() && hedgeTrade.IsOpened() == false && hedgeTrade.IsFilled() == false)
      status = HedgeStatus_Closed;

   else
      if(initialTrade.IsFilled() && hedgeTrade.IsFilled())
         status = HedgeStatus_Hedged;
      else
         if((initialTrade.IsFilled() && hedgeTrade.IsOpened()) || (initialTrade.IsOpened() && hedgeTrade.IsFilled()))
            status = HedgeStatus_Filled;
         else
            if((initialTrade.IsOpened() || initialTrade.IsCancelled()) && hedgeTrade.IsOpened())
               status = HedgeStatus_Open;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::TransitionToState(HedgeStatus newStatus)
  {
   _onStateEntry = true;
   lastStatus = status;
   status = newStatus;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::UpdateStatus2()
  {
   initialTrade.Update();
   hedgeTrade.Update();

   switch(status)
     {
      case HedgeStatus_None:
         if(initialTrade.IsOpened())
            TransitionToState(HedgeStatus_Open);
         if(initialTrade.IsFilled())
            TransitionToState(HedgeStatus_Filled);
         break;

      case HedgeStatus_Open:
         if(initialTrade.IsFilled())
            TransitionToState(HedgeStatus_Filled);
         if(initialTrade.IsCancelled())
            TransitionToState(HedgeStatus_Cancelled);
         break;

      case HedgeStatus_Filled:
         if(OnStateEntry())
            BalanceHedge();

         // balanced
         if((initialTrade.IsFilled() || initialTrade.IsOpened()) && (hedgeTrade.IsFilled() || hedgeTrade.IsOpened()))
            TransitionToState(HedgeStatus_Balanced);

         // both closed or cancelled
         if((initialTrade.IsClosed() && hedgeTrade.IsCancelled()) || (initialTrade.IsCancelled() && hedgeTrade.IsClosed()))
            TransitionToState(HedgeStatus_Closed);
         break;

      case HedgeStatus_Balanced:
         // Both filled
         if(initialTrade.IsFilled() && hedgeTrade.IsFilled())
            TransitionToState(HedgeStatus_Hedged);
         if((initialTrade.IsClosed() && hedgeTrade.IsOpened()) || (hedgeTrade.IsClosed() && initialTrade.IsOpened()))
            TransitionToState(HedgeStatus_Closing);
         break;

      case HedgeStatus_Hedged:
         if(initialTrade.IsClosed() || hedgeTrade.IsClosed())
            TransitionToState(HedgeStatus_Trimming);
         break;

      case HedgeStatus_Trimming:
         if(initialTrade.IsClosed())
            _collectedProfit += initialTrade.realizedPNL;
         else
            _collectedProfit += hedgeTrade.realizedPNL;
         if(TrimUsingProfit())
            TransitionToState(HedgeStatus_Trimmed);
         else
            TransitionToState(HedgeStatus_Filled);
         break;

      case HedgeStatus_Trimmed:
         if(initialTrade.IsFilled())
           {
            _collectedProfit += initialTrade.GetLastClosePNL();
           }
         if(hedgeTrade.IsFilled())
           {
            _collectedProfit += hedgeTrade.GetLastClosePNL();
           }
         TransitionToState(HedgeStatus_Filled);
         break;

      case HedgeStatus_Closing:
         // Close if not yet closed (due to external close)
         if(hedgeTrade.IsFilled())
            hedgeTrade.Close();
         if(initialTrade.IsFilled())
            initialTrade.Close();

         // Cancel opposing trade if still open
         if(!hedgeTrade.IsClosed() && !hedgeTrade.IsCancelled() && !hedgeTrade.IsNone())
            hedgeTrade.Cancel();
         if(!initialTrade.IsClosed() && !initialTrade.IsCancelled() && !initialTrade.IsNone())
            initialTrade.Cancel();

         if((initialTrade.IsClosed() || initialTrade.IsCancelled())
            && (hedgeTrade.IsClosed() || hedgeTrade.IsCancelled()))
           {
            TransitionToState(HedgeStatus_Closed);
           }

         break;

      case HedgeStatus_Closed:
         // do nothing
         break;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::CalculatePnl()
  {
// calculate pnl
   unrealizedPNL = initialTrade.unrealizedPNL + hedgeTrade.unrealizedPNL;
   realizedPNL = initialTrade.realizedPNL + hedgeTrade.realizedPNL;
   totalPNL = initialTrade.totalPNL + hedgeTrade.totalPNL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeTrade::Open(string _symbol, TradeDirection direction, double volume, double entry, double _profitDistance, double _hedgeDistance)
  {
   symbol = _symbol;
   initialHedgeDistance = _hedgeDistance;
   initialProfitDistance = _profitDistance;
   initialEntry = entry;
   hedgeDistance = initialHedgeDistance;
   profitDistance = initialProfitDistance;
   initialDirection = direction;
   if(direction == DirectionLong)
      initialHedgeEntry = initialEntry - initialHedgeDistance;
   else
      initialHedgeEntry = initialEntry + initialHedgeDistance;

// enter long or short depending on direction
   double tp = direction == DirectionLong ? entry + profitDistance : entry - profitDistance;
   return initialTrade.Enter(symbol, direction, volume, entry, tp, 0.0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeTrade::Close()
  {
   TransitionToState(HedgeStatus_Closing);
   return true;
  }

//+------------------------------------------------------------------+
void HedgeTrade::Init()
  {
   status = HedgeStatus_None;
   lastStatus = HedgeStatus_None;
   symbol = "";
   initialDirection = DirectionLong;
   initialTrade = new Trade(tradeManager);
   hedgeTrade = new Trade(tradeManager);

   realizedPNL = 0.0;
   unrealizedPNL = 0.0;
   totalPNL = 0.0;
  }
//+------------------------------------------------------------------+
void HedgeTrade::OpenHedge()
  {
   if(hedgeTrade.IsFilled() == false && hedgeTrade.IsOpened() == false)
     {
      TradeDirection direction;
      double entry;
      if(initialDirection == DirectionLong)
        {
         direction = DirectionShort;
         entry = initialTrade.averageEntry - hedgeDistance;
        }
      else
        {
         direction = DirectionLong;
         entry = initialTrade.averageEntry + hedgeDistance;
        }
      double volume = initialTrade.totalVolume;
      double tp = direction == DirectionLong ? entry + profitDistance : entry - profitDistance;
      hedgeTrade.SetStopOrder(symbol, direction, volume, entry, tp);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::SetHedgeDistance(double distance)
  {
   if(hedgeTrade.IsFilled())
      return;
   hedgeDistance = distance;

// open hedge if hedge is not yet opened
   if(hedgeTrade.IsOpened() == false)
     {
      OpenHedge();
     }
   else
      if(hedgeTrade.IsOpened() == true)
        {
         hedgeTrade.Cancel();
         OpenHedge();
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::ResetHedgeDistance()
  {
   if(hedgeTrade.IsFilled())
      return;
   hedgeDistance = initialHedgeDistance;

// open hedge if hedge is not yet opened
   if(hedgeTrade.IsOpened() == false)
      OpenHedge();
   else
      if(hedgeTrade.IsOpened() == true)
        {
         hedgeTrade.Cancel();
         OpenHedge();
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::SetProfitDistance(double distance)
  {
   profitDistance = distance;
   if(initialTrade.IsFilled() == true || initialTrade.IsOpened() == true)
     {
      initialTrade.SetTakeProfitRel(profitDistance);
     }
   if(hedgeTrade.IsFilled() == true || hedgeTrade.IsOpened() == true)
     {
      hedgeTrade.SetTakeProfitRel(profitDistance);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeTrade::ResetProfitDistance()
  {
   profitDistance = initialProfitDistance;
   if(initialTrade.IsFilled() == true || initialTrade.IsOpened() == true)
     {
      initialTrade.SetTakeProfitRel(profitDistance);
     }
   if(hedgeTrade.IsFilled() == true || hedgeTrade.IsOpened() == true)
     {
      hedgeTrade.SetTakeProfitRel(profitDistance);
     }
  }
//+------------------------------------------------------------------+
