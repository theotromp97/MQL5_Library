//+------------------------------------------------------------------+
//|                                                   HedgeTrade.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Theo"
#property link      "https://www.mql5.com"
#property version "1.00"

#include <MQL5_Library\Trade\Trade.mqh>


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HedgeTrade
  {
private:
   CTrade            tradeManager;
   TradeStatus       lastStatus;
   bool              hedgeProtected;
   bool              hedgeOpened;
   bool              hedgeFilled;

   void              Init();
   void              OpenHedge();
   void              Apply(double amount);         // trim the hedge by using other trades profit

public:
   string            symbol;
   TradeDirection    initialDirection;
   TradeStatus       status;

   double            initialHedgeDistance;
   double            initialProfitDistance;
   double            hedgeDistance;
   double            profitDistance;

   bool              HedgeProtected() {return hedgeProtected;}
   bool              HedgeOpened() {return hedgeOpened;}
   bool              FedgeFilled() {return hedgeFilled;}

   bool              HedgeProtectedOS() {return hedgeProtected && lastStatus != status;}
   bool              HedgeOpenedOS() {return hedgeOpened && lastStatus != status;}
   bool              FedgeFilledOS() {return hedgeFilled && lastStatus != status;}

   void              SetHedgeDistance(double distance);
   void              ResetHedgeDistance();

   void              SetProfitDistance(double distance);
   void              ResetProfitDistance();

   Trade             initialTrade;
   Trade             hedgeTrade;

   double            realizedPNL;
   double            unrealizedPNL;
   double            totalPNL;

                     HedgeTrade() {}
                     HedgeTrade(CTrade& _tradeManager)
     {
      tradeManager = _tradeManager;
      initialTrade = new Trade(tradeManager);
      hedgeTrade = new Trade(tradeManager);
     }

   void              Open(string _symbol, TradeDirection direction, double volume, double entry, double _profitDistance, double _hedgeDistance)
     {
      symbol = _symbol;
      initialHedgeDistance = _hedgeDistance;
      initialProfitDistance = _profitDistance;
      hedgeDistance = initialHedgeDistance;
      profitDistance = initialProfitDistance;
      initialDirection = direction;


      // enter long or short depending on direction
      double tp = direction == DirectionLong ? entry + profitDistance : entry - profitDistance;
      initialTrade.Enter(symbol, direction, volume, entry, tp, 0.0);
     }

   // Updater function: update trade statusses pnl calculation, and handles opening the hedge
   void              Update()
     {
      // update trades
      initialTrade.Update();
      hedgeTrade.Update();

      // open / close hedge
      if(initialTrade.IsFilled())
        {
        
         OpenHedge();
        }

      // calculate pnl
      unrealizedPNL = initialTrade.unrealizedPNL + hedgeTrade.unrealizedPNL;
      realizedPNL = initialTrade.realizedPNL + hedgeTrade.realizedPNL;
      totalPNL = initialTrade.totalPNL + hedgeTrade.totalPNL;

     }
  };

//+------------------------------------------------------------------+
void HedgeTrade::Init()
  {
   lastStatus = Status_None;
   symbol = "";
   initialDirection = DirectionLong;
   status = Status_None;
   initialTrade = new Trade(tradeManager);
   initialTrade = new Trade(tradeManager);

   hedgeProtected = false;
   hedgeOpened = false;
   hedgeFilled = false;

   realizedPNL = 0.0;
   unrealizedPNL = 0.0;
   totalPNL = 0.0;
  }
//+------------------------------------------------------------------+
void HedgeTrade::OpenHedge()
  {
   if(hedgeTrade.IsFilled() == false && hedgeTrade.IsOpened() == false && hedgeTrade.IsClosed() == false)
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              HedgeTrade::SetHedgeDistance(double distance)
  {
   if(hedgeTrade.IsFilled())
      return;
   hedgeDistance = distance;

// open hedge if hedge is not yet opened
   if(hedgeTrade.IsOpened() == false)
      OpenHedge();
   else
      if(hedgeTrade.IsOpened() == true)
        {
         hedgeTrade.Cancel();
         OpenHedge();
        }
//hedgeTrade
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              HedgeTrade::ResetHedgeDistance()
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
void              HedgeTrade::SetProfitDistance(double distance)
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
void              HedgeTrade::ResetProfitDistance()
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
