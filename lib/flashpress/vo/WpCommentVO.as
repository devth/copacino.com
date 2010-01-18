/**
* Copyright 2009 __noponies__
*
*/

package flashpress.vo {
	/**
	 *	WpCommentVO Value Object.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Dale Sattler
	 *	@since  26.02.2009
	 */
  [RemoteClass(alias="flashpress.vo.WpCommentVO")]  
  

  public class WpCommentVO {

    // CLASS VARIABLES 

    public var comment_ID:int;
    public var comment_post_ID:int;
    public var comment_author:String;
    public var comment_author_email:String;
    public var comment_author_url:String;
    public var comment_author_IP:String;
    public var comment_date:String;
    public var comment_date_gmt:String;
    public var comment_content:String;
    public var comment_karma:int;
    public var comment_approved:int;
    public var comment_agent:String;
    public var comment_type:String;
    public var comment_parent:int;
    public var user_id:int;

    // CONSTRUCTOR 

    function WpCommentVO():void {}

  }
}