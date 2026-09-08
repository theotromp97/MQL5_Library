enum HedgeStatus
{
   HedgeStatus_None,             // nothing active
   HedgeStatus_Open,             // main trade pending
   HedgeStatus_Filled,           // One trade filled, open the other trade
   HedgeStatus_Balanced,         // Both trade are entered of filled
   HedgeStatus_Hedged,           // main trade filled and hedge filled 
   HedgeStatus_Trimming,         // Trim losing trade
   HedgeStatus_Trimmed,         // Trimmed used for profit calculation
   HedgeStatus_Closed,           // Both sides closed / None
   HedgeStatus_Closing,           // Both sides closed / None
   HedgeStatus_Cancelled,        // Both sides cancelled / None
};