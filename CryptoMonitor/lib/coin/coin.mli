type triggerer = Price | Profit | PriceAndProfit

type coin =
    Coin of string * float * string * float * float * bool * triggerer
  | Inapplicable
