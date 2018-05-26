package com.nguyenanh.ex3.api;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import rx.Observable;
import rx.Subscriber;

public class Provider {
    private static Element queryServer(String url) {
        Element js = null;
        try {
            Document document = (Document) Jsoup.connect(url).get();
            Element element = document.body();
            js = element.getElementById("jobs");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Element sub = document.body();
        return js;
    }

    public static Observable<Element> getJobs(final String url) {
        return Observable.create(new Observable.OnSubscribe<Element>() {
            @Override
            public void call(Subscriber<? super Element> subscriber) {

                Element element = queryServer(url);
                try {
                    subscriber.onNext(element);
                    subscriber.onCompleted();
                }catch (Exception e){
                    subscriber.onError(e);
                }

            }
        });
    }
}
