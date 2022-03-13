//
//  StockChartView.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 27/11/21.
//

import UIKit
import Charts

/// View to show chart
final class StockChartView: UIView {
    
    /// Chart View ViewModel
    struct ViewModel {
        let data:[Double]
        let showLegend:Bool
        let showAxisBool:Bool
        let fillColor:UIColor
    }
    
    /// Chart View
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(false)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false 
        return chartView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    /// Reset Chart View
    public func reset() {
        chartView.data = nil
    }
    
    /// Configure View
    /// - Parameter viewModel: View ViewModel
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        
        for ( index, value) in viewModel.data.enumerated()
        {
            entries.append(
                .init(
                    x: Double(index),
                    y: value
                ))
        }
        
        chartView.xAxis.enabled = viewModel.showAxisBool
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawCirclesEnabled = false
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
    
}
