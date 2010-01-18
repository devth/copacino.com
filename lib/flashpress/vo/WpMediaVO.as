/**
* Copyright 2009 __noponies__
*
*/

package flashpress.vo {
	/**
	 *	WpMediaVO Value Object.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Dale Sattler
	 *	@since  26.02.2009
	 */ 
  [RemoteClass(alias="flashpress.vo.WpMediaVO")]  
  
  public class WpMediaVO {

    // CLASS VARIABLES 
    public var id:int;
    public var post_author:int;
    public var post_date:String;
    public var post_date_gmt:String;
    public var post_content:String;
    public var post_title:String;
    public var post_category:int;
    public var post_excerpt:String;
	public var post_status:String;
    public var comment_status:String;
    public var ping_status:String;
	public var post_password:String;
    public var post_name:String;
    public var to_ping:String;
    public var pinged:String;
    public var post_modified:String;
    public var post_modified_gmt:String;
    public var post_content_filtered:String;
    public var post_parent:int;
    public var guid:String;
    public var menu_order:Number;
    public var post_type:String;
    public var post_mime_type:String;
    public var comment_count:int;
    public var url:String;

    // CONSTRUCTOR 

    function WpMediaVO():void {}

  }
}