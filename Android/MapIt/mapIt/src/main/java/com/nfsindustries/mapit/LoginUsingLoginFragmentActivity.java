package com.nfsindustries.mapit;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import java.util.Arrays;

public class LoginUsingLoginFragmentActivity extends FragmentActivity {

    CallbackManager callbackManager;

    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        setContentView(R.layout.fb_login_fragment_activity);

        FacebookSdk.sdkInitialize(this.getApplicationContext());

        callbackManager = CallbackManager.Factory.create();
        final LoginButton loginButton = (LoginButton)findViewById(R.id.fb_login_button);
        loginButton.setReadPermissions(Arrays.asList("user_about_me", "user_hometown", "user_location", "friends_hometown", "read_friendlists", "friends_location"));
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        // App code
                    }

                    @Override
                    public void onCancel() {
                        // App code
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        // App code
                    }
                });

    }
}
