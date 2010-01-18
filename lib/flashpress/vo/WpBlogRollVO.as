/**
* Copyright 2009 __noponies__
*
*/

package flashpress.vo {
	/**
	 *	WpBlogRollVO Value Object.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Dale Sattler
	 *	@since  26.02.2009
	 */
  [RemoteClass(alias="flashpress.vo.WpBlogRollVO")]  
   

  public class WpBlogRollVO {

    // CLASS VARIABLES 

    public var link_id:int;
    public var link_url:String;
    public var link_name:String;
    public var link_image:String;
    public var link_target:String;
    public var link_category:int;
    public var link_description:String;
    public var link_visible:String;
    public var link_owner:int;
    public var link_rating:int;
    public var link_updated:String;
    public var link_rel:String;
    public var link_notes:String;
    public var link_rss:String;

    // CONSTRUCTOR 

    function WpBlogRollVO():void {}

  }
}