package com.nguyenanh.ex3.home;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;

import com.nguyenanh.ex3.R;

public class HomeActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.home_activity);

        getSupportFragmentManager().beginTransaction().replace(R.id.frame_content,HomeFragment.newInstance()).commit();
    }
}
