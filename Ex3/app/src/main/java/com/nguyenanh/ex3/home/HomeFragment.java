package com.nguyenanh.ex3.home;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Spinner;

import com.hannesdorfmann.mosby3.mvp.MvpFragment;
import com.nguyenanh.ex3.R;
import com.nguyenanh.ex3.home.adapter.AdapterListJobs;

import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.ArrayList;

public class HomeFragment extends MvpFragment<HomeView,HomePresent> implements HomeView , AdapterListJobs.ISaveLike{
    private RecyclerView listJobs;
    private SharedPreferences sharedPref;
    private Spinner skill;
    private Spinner local;
    private Button btn;


    public static HomeFragment newInstance(){
        HomeFragment homeFragment = new HomeFragment();

        return homeFragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.home_fragment, container, false);
        listJobs = view.findViewById(R.id.list_jobs);
        skill = view.findViewById(R.id.skill);
        local = view.findViewById(R.id.local);
        btn = view.findViewById(R.id.find);

        String arr[]={
                "android",
                "java",
                "php",
                "ios",
                "javascript"};

        ArrayAdapter<String> adapter=new ArrayAdapter<String>(getContext(), android.R.layout.simple_spinner_item, arr);

        adapter.setDropDownViewResource
                (android.R.layout.simple_list_item_single_choice);
        //Thiết lập adapter cho Spinner
        skill.setAdapter(adapter);

        String arr1[]={
                "ha-noi",
                "ho-chi-minh-hcm"};
        ArrayAdapter<String> adapter1 =new ArrayAdapter<String>(getContext(), android.R.layout.simple_spinner_item, arr1);
        adapter1.setDropDownViewResource
                (android.R.layout.simple_list_item_single_choice);
        //Thiết lập adapter cho Spinner
        local.setAdapter(adapter1);

        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getPresenter().getJobs(skill.getSelectedItem().toString(),local.getSelectedItem().toString());
            }
        });

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        getPresenter().getJobs("","ho-chi-minh-hcm");
    }

    @Override
    public HomePresent createPresenter() {
        return new HomePresent();
    }

    @Override
    public void showJobs(Element element) {

        sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
        ArrayList<Element> jobs = new ArrayList<>();
        Elements element1 = element.getElementsByClass("first-group");

        Elements element2 = element1.get(0).getElementsByClass("job");
        GridLayoutManager layoutManager = new GridLayoutManager(getContext(),2);
        AdapterListJobs adapterListJobs = new AdapterListJobs(getContext(), element2, this, sharedPref);

        listJobs.setLayoutManager(layoutManager);
        listJobs.setAdapter(adapterListJobs);

    }

    @Override
    public void saveLike(String id) {
        SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        String like = sharedPref.getString(id, "khong");
        if (like.equals("co")){
            editor.remove(id);
        }else {
            editor.putString(id, "co");
        }
        editor.commit();
    }


}
