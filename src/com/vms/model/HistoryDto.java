package com.vms.model;

public class HistoryDto {
	private double lat;
    private double lng;
    private String recordedTime;
	
	
    public double getLat() {
		return lat;
	}
	public void setLat(double lat) {
		this.lat = lat;
	}
	public double getLng() {
		return lng;
	}
	public void setLng(double lng) {
		this.lng = lng;
	}
	public String getRecordedTime() {
		return recordedTime;
	}
	public void setRecordedTime(String recordedTime) {
		this.recordedTime = recordedTime;
	}
}