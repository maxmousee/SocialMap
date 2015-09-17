package com.nfsindustries.mapit;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.ListActivity;
import android.os.Bundle;
import android.widget.ListView;
import android.widget.SimpleAdapter;

public class UsersListActivity extends ListActivity {
	private ListView usersListView;
	List<Map<String, String>> usersListMap = new ArrayList<Map<String,String>>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//setContentView(R.layout.view_users_list_activity);
		usersListView = getListView();
		initList(getIntent().getStringArrayListExtra("users"));
		SimpleAdapter simpleAdpt = new SimpleAdapter(this, usersListMap, android.R.layout.simple_list_item_1, new String[] {"name"}, new int[] {android.R.id.text1});
		usersListView.setAdapter(simpleAdpt);
	}
	
	private void initList(ArrayList<String> users) {
		Collections.sort(users);
		// We populate the users
		for(String userName : users) {
			usersListMap.add(createUser("name", userName));
		}
	}
	
	private HashMap<String, String> createUser(String key, String name) {
		HashMap<String, String> user = new HashMap<String, String>();
		user.put(key, name);
		return user;
	}

}
