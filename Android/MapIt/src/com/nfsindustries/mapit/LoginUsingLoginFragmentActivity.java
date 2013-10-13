package com.nfsindustries.mapit;

import android.content.Intent;

import android.os.Bundle;

import android.support.v4.app.FragmentActivity;

import android.support.v4.app.FragmentManager;

import android.util.Log;

import com.facebook.Session;

import com.facebook.SessionState;

import com.facebook.widget.UserSettingsFragment;



public class LoginUsingLoginFragmentActivity extends FragmentActivity {

    private UserSettingsFragment userSettingsFragment;



    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);



        setContentView(R.layout.fb_login_fragment_activity);



        FragmentManager fragmentManager = getSupportFragmentManager();

        userSettingsFragment = (UserSettingsFragment) fragmentManager.findFragmentById(R.id.login_fragment);

        userSettingsFragment.setSessionStatusCallback(new Session.StatusCallback() {

            @Override

            public void call(Session session, SessionState state, Exception exception) {

                Log.d("LoginUsingLoginFragmentActivity", String.format("New session state: %s", state.toString()));

            }

        });

    }



    @Override

    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        userSettingsFragment.onActivityResult(requestCode, resultCode, data);

        super.onActivityResult(requestCode, resultCode, data);

    }



}
