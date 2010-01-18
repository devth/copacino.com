/**
* Copyright 2009 __noponies__
*
*/

package flashpress.vo {
	/**
	 *	WpOptionVO Value Object.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Dale Sattler
	 *	@since  26.02.2009
	 */ 
  [RemoteClass(alias="flashpress.vo.WpOptionVO")]  
  

  public class WpOptionVO {

    // CLASS VARIABLES 
   public var option_id:int;
   public var blog_id:int;
   public var option_name:String;
   public var option_value:String;
   public var autoload:String;

    // CONSTRUCTOR 
    function WpOptionVO():void {}

  }
}