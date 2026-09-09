#property copyright "Theo"
#property link      "https://www.mql5.com"
#property version   "1.00"


enum TradeBasketStatus
  {
   BasketStatus_None,
   BasketStatus_Open,
   BasketStatus_PartialFilled,
   BasketStatus_Filled,
   BasketStatus_Closed,
   BasketStatus_Cancelled
  };