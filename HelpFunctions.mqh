//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename T>
void SwapArray(T &array[], int position1, int position2)
  {
   T temp = array[position1];
   array[position1] = array[position2];
   array[position2] = temp;
  }
//+------------------------------------------------------------------+


template <typename T>
void AddArray(T &array[], T &t)
  {
   ArrayResize(array, ArraySize(array) + 1);
   array[ArraySize(array) - 1] = t;
  }
//+------------------------------------------------------------------+
