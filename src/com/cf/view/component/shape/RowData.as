package com.cf.view.component.shape
{
	public class RowData extends Object
	{
		
		public var weight:Number;
		public var row:int;
		
		public function RowData(row:int, weight:Number)
		{
			this.row = row;
			this.weight = weight;
		}
		
		
		
		public function toString() : String
		{
			return "row: " + row + ", weight: " + weight;
		}
		
	}
}