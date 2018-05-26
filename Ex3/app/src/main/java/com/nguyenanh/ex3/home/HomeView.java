package com.nguyenanh.ex3.home;

import com.hannesdorfmann.mosby3.mvp.MvpView;

import org.jsoup.nodes.Element;

public interface HomeView extends MvpView {
    void showJobs(Element element);
}
