package com.nfsindustries.mapit;

import com.facebook.Session;
import com.facebook.SessionState;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

public class SelectionActivity extends Activity {
	static final int FACEBOOK_LOGIN_REQUEST = 1;  // The request code
	ImageView showFacebookMapButton;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_selection);
		showFacebookMapButton = (ImageView)findViewById(R.id.mapFacebookButton);
		showFacebookMapButton.setOnClickListener(new OnClickListener(){
	        @Override
	        //On click function
	        public void onClick(View view) {
	        	Intent facebookMapIntent = new Intent(SelectionActivity.this, FacebookMapActivity.class);
	        	startActivity(facebookMapIntent);
	        }
	    });
	}
	
	@Override
	protected void onResume()
	{
		super.onResume();
		//start Facebook Login
		  Session.openActiveSession(this, true, new Session.StatusCallback() {

		    // callback when session changes state
			@Override
			public void call(Session session, SessionState state,
					Exception exception) {
				
		        if (session.isOpened()) {
		        	showFacebookMapButton.setVisibility(View.VISIBLE);
		        }
		        else {
		        	showFacebookMapButton.setVisibility(View.GONE);
		        }
				
			}
		  }); 
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.selection, menu);
		return true;
	}
	
	@Override
	  public void onActivityResult(int requestCode, int resultCode, Intent data) {
	      super.onActivityResult(requestCode, resultCode, data);
	      Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
	  }
}
