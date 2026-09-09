#property copyright "Theo"
#property link      "https://www.mql5.com"
#property version   "1.00"


enum TradeBasketStatus
  {
   DcaStatus_None,
   DcaStatus_Open,
   DcaStatus_PartialFilled,
   DcaStatus_Filled,
   DcaStatus_Closed,
   DcaStatus_Cancelled
  };