package com.nfsindustries.mapit;

import java.util.Arrays;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class SelectionActivity extends Activity {
	static final int FACEBOOK_LOGIN_REQUEST = 1;  // The request code
	Button currentLocBtn;
	Button hometownBtn;
	TextView fbInfoTV;
    CallbackManager callbackManager;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_selection);

		currentLocBtn = (Button)findViewById(R.id.currentLocationButton);
		hometownBtn = (Button)findViewById(R.id.homeTownButton);
		fbInfoTV = (TextView)findViewById(R.id.textView1);


		setContentView(R.layout.fb_login_fragment_activity);

		FacebookSdk.sdkInitialize(this.getApplicationContext());

		callbackManager = CallbackManager.Factory.create();
		final LoginButton loginButton = (LoginButton)findViewById(R.id.fb_login_button);
		loginButton.setReadPermissions(Arrays.asList("user_about_me", "user_hometown", "user_location", "friends_hometown", "read_friendlists", "friends_location"));
		LoginManager.getInstance().registerCallback(callbackManager,
				new FacebookCallback<LoginResult>() {
					@Override
					public void onSuccess(LoginResult loginResult) {
                        currentLocBtn.setVisibility(View.VISIBLE);
                        fbInfoTV.setVisibility(View.VISIBLE);
                        hometownBtn.setVisibility(View.VISIBLE);
                    }

					@Override
					public void onCancel() {
                        currentLocBtn.setVisibility(View.GONE);
                        fbInfoTV.setVisibility(View.GONE);
                        hometownBtn.setVisibility(View.GONE);
                    }

					@Override
					public void onError(FacebookException exception) {
                        currentLocBtn.setVisibility(View.GONE);
                        fbInfoTV.setVisibility(View.GONE);
                        hometownBtn.setVisibility(View.GONE);
                    }
				});

		loginButton.setReadPermissions(Arrays.asList("user_about_me", "user_hometown", "user_location", "friends_hometown", "read_friendlists", "friends_location"));
		Log.d("ANDROID_API_LEVEL", "" + Integer.valueOf(android.os.Build.VERSION.SDK_INT));

		currentLocBtn.setOnClickListener(new OnClickListener(){
			@Override
			//On click function
			public void onClick(View view) {
				Intent facebookCurrentLocationMapIntent = new Intent(SelectionActivity.this, FacebookMapActivity.class);
				facebookCurrentLocationMapIntent.putExtra("current_location", true);
				startActivity(facebookCurrentLocationMapIntent);
			}
		});

		hometownBtn.setOnClickListener(new OnClickListener(){
			@Override
			//On click function
			public void onClick(View view) {
				Intent facebookHometownMapIntent = new Intent(SelectionActivity.this, FacebookMapActivity.class);
				facebookHometownMapIntent.putExtra("current_location", false);
				startActivity(facebookHometownMapIntent);
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
		Log.d("onActivityResult", "" + resultCode);
		super.onActivityResult(requestCode, resultCode, data);
	}
}
