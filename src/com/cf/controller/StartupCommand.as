package com.cf.controller
{
	import com.cf.ApplicationFacade;
	import com.cf.model.StageProxy;
	import com.cf.util.Utility;
	import com.cf.view.DestinationStateMediator;
	import com.cf.view.StageMediator;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Stage;
	import flash.net.registerClassAlias;
	
	import flashpress.vo.WpBlogRollVO;
	import flashpress.vo.WpCategoryVO;
	import flashpress.vo.WpCommentVO;
	import flashpress.vo.WpMediaVO;
	import flashpress.vo.WpOptionVO;
	import flashpress.vo.WpPostCategoryVO;
	import flashpress.vo.WpPostVO;
	import flashpress.vo.WpPostWithTagAndCatVO;
	import flashpress.vo.WpTagVO;
	import flashpress.vo.WpUserVO;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.utilities.statemachine.FSMInjector;

	public class StartupCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void
		{
			Utility.debugColor( "===============================", 0x0000FF );
			Utility.debugColor( "Starting up " + new Date(), 0x0000FF );
			Utility.debugColor( "===============================", 0x0000FF );
			
			var stage:Stage = notification.getBody() as Stage;
			
			// STAGE mediator
			facade.registerMediator( new StageMediator( stage ) );
			
			// STAGE proxy
			facade.registerProxy( new StageProxy( stage ) );
			
			
			// REGISTER destination state mediator
			facade.registerMediator( new DestinationStateMediator() );
			
			// CLASS MAPPINGS for AMFPHP
			registerClassAlias("flashpress.vo.WpBlogRollVO", WpBlogRollVO);
			registerClassAlias("flashpress.vo.WpCategoryVO", WpCategoryVO);
			registerClassAlias("flashpress.vo.WpCommentVO", WpCommentVO);
			registerClassAlias("flashpress.vo.WpMediaVO", WpMediaVO);
			registerClassAlias("flashpress.vo.WpOptionVO", WpOptionVO);
			registerClassAlias("flashpress.vo.WpPostCategoryVO", WpPostCategoryVO);
			registerClassAlias("flashpress.vo.WpPostVO", WpPostVO);
			registerClassAlias("flashpress.vo.WpTagVO", WpTagVO);
			registerClassAlias("flashpress.vo.WpUserVO", WpUserVO);
			registerClassAlias("flashpress.vo.WpPostWithTagAndCatVO", WpPostWithTagAndCatVO);
			
			// MOUSEWHEEL for mac
			MacMouseWheel.setup( stage );
			
			// CREATE FSM DEFINITION
			var fsm:XML =
				<fsm initial={CF.STATE_WE_ARE}>
					<state name={CF.STATE_LOADING}>
						<transition action={CF.TO_WE_ARE} target={CF.STATE_WE_ARE} />
						<transition action={CF.TO_WE_ARE_NOT} target={CF.STATE_WE_ARE_NOT} />
					</state>
					<state name={CF.STATE_WE_ARE}>
						<transition action={CF.TO_WE_ARE_NOT} target={CF.STATE_WE_ARE_NOT} />
//						<transition action={CF.TO_WE_ARE_LIST} target={CF.STATE_WE_ARE_LIST} />
					</state>
					<state name={CF.STATE_WE_ARE_NOT}>
						<transition action={CF.TO_WE_ARE} target={CF.STATE_WE_ARE} />
//						<transition action={CF.TO_WE_ARE_NOT_LIST} target={CF.STATE_WE_ARE_NOT_LIST} />
					</state>
//					<state name={CF.STATE_WE_ARE_LIST}>
//						<transition action={CF.TO_WE_ARE} target={CF.STATE_WE_ARE} />
//						<transition action={CF.TO_WE_ARE_CONTENT} target={CF.STATE_WE_ARE_CONTENT} />
//					</state>
//					<state name={CF.STATE_WE_ARE_CONTENT}>
//						<transition action={CF.TO_WE_ARE_LIST} target={CF.STATE_WE_ARE_LIST} />
//						<transition action={CF.TO_WE_ARE_FULLSCREEN} target={CF.STATE_WE_ARE_FULLSCREEN} />
//					</state>
//					<state name={CF.STATE_WE_ARE_FULLSCREEN}>
//						<transition action={CF.TO_WE_ARE_CONTENT} target={CF.STATE_WE_ARE_CONTENT} />
//					</state>
//					<state name={CF.STATE_WE_ARE_NOT_LIST}>
//						<transition action={CF.TO_WE_ARE_NOT} target={CF.STATE_WE_ARE_NOT} />
//						<transition action={CF.TO_WE_ARE_NOT_CONTENT} target={CF.STATE_WE_ARE_NOT_CONTENT} />
//					</state>
//					<state name={CF.STATE_WE_ARE_NOT_CONTENT}>
//						<transition action={CF.TO_WE_ARE_NOT_LIST} target={CF.STATE_WE_ARE_NOT_LIST} />
//						<transition action={CF.TO_WE_ARE_NOT_FULLSCREEN} target={CF.STATE_WE_ARE_NOT_FULLSCREEN} />
//					</state>
//					<state name={CF.STATE_WE_ARE_NOT_FULLSCREEN}>
//						<transition action={CF.TO_WE_ARE_NOT_CONTENT} target={CF.STATE_WE_ARE_NOT_CONTENT} />
//					</state>
				</fsm>;
				
			
			// INJECT the StateMachine
			var injector:FSMInjector = new FSMInjector( fsm );
			injector.inject();
			
			// INIT SITE
			sendNotification( ApplicationFacade.INITIALIZE_SITE );
		}
		
	}
}