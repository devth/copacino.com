/**
* Copyright 2009 __noponies__
*
*/

package flashpress.vo {
	/**
	 *	WpTagVO Value Object.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Dale Sattler
	 *	@since  26.02.2009
	 */ 
  [RemoteClass(alias="flashpress.vo.WpTagVO")]  
  

  public class WpTagVO {

    // CLASS VARIABLES 
   public var term_id:int;	  
   public var name:String;
   public var slug:String;
   public var count:int;

    // CONSTRUCTOR 
    function WpTagVO():void {}

  }
}