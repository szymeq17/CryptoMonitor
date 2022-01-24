type triggerer = Price | Profit | PriceAndProfit

(* type coin =
  {symbol:                 string;
   target_price:           float;
   currency:               string;
   pocket:                 float;
   target_profit:          float;
   applicable:             bool;
   notification_triggerer: triggerer} *)
type coin = 
  | Coin of string * float * string * float * float * bool * triggerer 
  | Inapplicable
