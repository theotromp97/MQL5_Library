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

template <typename T>
bool RemoveFromArray(T &array[], int index)
  {
   int size = ArraySize(array);

// Validate the index
   if(index < 0 || index >= size)
     {
      return false;
     }

// For fixed-size arrays, shift elements left
   for(int i = index; i < size - 1; i++)
     {
      array[i] = array[i + 1];
     }

// Resize the array
   return ArrayResize(array, size - 1) != -1;
  }

//+------------------------------------------------------------------+

template <typename T>
bool RemoveFromArrayByValue(T &array[], T &value)
  {
   int size = ArraySize(array);
   int index = 0;

// Validate the index
   if(index < 0 || index >= size)
     {
      return false;
     }

// loop through array and find value
   for(int i = index; i < size - 1; i++)
     {
      if(array[i] == value)
        {
         index = i;
         break;
        }
     }

// For fixed-size arrays, shift elements left
   for(int i = index; i < size - 1; i++)
     {
      array[i] = array[i + 1];
     }

// Resize the array
   return ArrayResize(array, size - 1) != -1
//return
  }
//+------------------------------------------------------------------+


template <typename T>
int FindIndexInArray(T &array[], T &value)
  {
   int size = ArraySize(array);
   int index = 0;

// Validate the index
   if(index < 0 || index >= size)
      return false;

// loop through array and find value
   for(int i = index; i < size - 1; i++)
     {
      if(array[i] == value)
        {
         return i;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
