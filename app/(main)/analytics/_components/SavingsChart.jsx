"use client";

import { useEffect, useState } from "react";
import { useUser } from "@/app/provider";
import { useDataRefresh } from "@/context/DataRefreshContext";
import { getUserTransactions, getUserJarBalances, getUserSavingTarget } from "@/services/accumulativeFinancialService";
import { Line } from "react-chartjs-2";
import axios from "axios";

import {
  Chart as ChartJS,
  TimeScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import "chartjs-adapter-date-fns";

ChartJS.register(
  TimeScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

export default function SavingsChart() {
  const { user } = useUser();
  const { refreshTrigger } = useDataRefresh();
  const [dataPoints, setDataPoints] = useState([]);
  const [labels, setLabels] = useState([]);
  const [forecastLabels, setForecastLabels] = useState([]);
  const [forecastPoints, setForecastPoints] = useState([]);
  const [savingTarget, setSavingTarget] = useState(0);
  const [loading, setLoading] = useState(true);
  const [forecastLoading, setForecastLoading] = useState(false);

  useEffect(() => {
    if (!user?.id) return;
    console.log("SavingsChart: Refreshing data, refreshTrigger:", refreshTrigger);
    setLoading(true);

    // 1) Get the user's saving target
    getUserSavingTarget(user.id).then(async (target) => {
      console.log("SavingsChart: Saving target fetched:", target / 100);
      setSavingTarget(target / 100); // Convert cents to VND units
    }).catch(err => {
      console.error("Error fetching saving target:", err);
      setSavingTarget(0);
    });

    // 2) Get the Savings jar
    getUserJarBalances(user.id).then(async (jars) => {
      const savingsJar = jars.find((jar) => jar.category_name === "Savings");
      if (!savingsJar) {
        setLabels([]);
        setDataPoints([]);
        setForecastLabels([]);
        setForecastPoints([]);
        setLoading(false);
        return;
      }

      // 2) Fetch transactions & build daily cumulative
      getUserTransactions(user.id, 1000, 0, { jarCategoryId: savingsJar.category_id })
      .then(async (transactions) => {
        const daily = {};
        let runningBalance = 0;
        transactions
          .sort((a, b) => new Date(a.occurred_at) - new Date(b.occurred_at))
          .forEach((tx) => {
            const day = tx.occurred_at.slice(0, 10);
            runningBalance += (tx.amount_cents || 0);
            daily[day] = runningBalance;
          });

        const sortedDays = Object.keys(daily).sort();
        const balances = sortedDays.map((d) => daily[d]);

        setLabels(sortedDays);
        setDataPoints(balances);
        setLoading(false);

        // 3) Prepare monthly data & call forecast
        if (sortedDays.length) {
          setForecastLoading(true);

          const monthlyData = [];
          let lastMonth = null, lastDate = null, lastBalance = null;
          sortedDays.forEach((date, idx) => {
            const month = date.slice(0, 7);
            if (month !== lastMonth && lastDate) {
              monthlyData.push({ date: lastDate, balance: lastBalance });
              lastMonth = month;
            }
            lastDate = date;
            lastBalance = balances[idx];
          });
          if (lastDate) {
            monthlyData.push({ date: lastDate, balance: lastBalance });
          }

          try {
            const { data } = await axios.post(process.env.NEXT_PUBLIC_FORECAST_API_URL, {
              data: monthlyData,
              periods: 6,
              freq: "M",
              target: 10000.0,
              lags: 12
            });
            
            // Filter forecast to only include dates after the last actual date
            const lastActualDate = new Date(sortedDays[sortedDays.length - 1]);
            console.log("forecast: ", data)
            const parsed = JSON.parse(data.body);
            console.log(parsed.forecast); // This will be your array!
            const filteredForecast = parsed.forecast.filter(f => {
              const forecastDate = new Date(f.date);
              return forecastDate > lastActualDate;
            });
            
            setForecastLabels(filteredForecast.map((f) => f.date));
            setForecastPoints(filteredForecast.map((f) => f.yhat));
          } catch (err) {
            console.error("Forecast API error", err);
            setForecastLabels([]);
            setForecastPoints([]);
          } finally {
            setForecastLoading(false);
          }
        }
      });
    });
  }, [user?.id, refreshTrigger]);

  // Build the datasets with {x,y} points
  const actualDataset = {
    label: "Actual Savings (VND)",
    data: labels.map((d, i) => ({ x: d, y: dataPoints[i] })),
    borderColor: "#10b981",
    backgroundColor: "#d1fae5",
    tension: 0.3,
    spanGaps: true,
  };

  const forecastDataset = {
    label: "Forecast (VND)",
    data: labels.length && forecastLabels.length
      ? [
          // Start from the last actual point for smooth connection
          { x: labels[labels.length - 1], y: dataPoints[dataPoints.length - 1] },
          // Then add all forecast points (these should be future dates only)
          ...forecastLabels.map((d, i) => ({ x: d, y: forecastPoints[i] }))
        ]
      : [],
    borderColor: "#f59e42",
    borderDash: [8, 4],
    backgroundColor: "rgba(245, 158, 66, 0.1)",
    tension: 0.3,
    spanGaps: true,
    pointRadius: (context) => {
      // Hide the first point (connection point) to avoid overlap
      return context.dataIndex === 0 ? 0 : 3;
    },
    // Ensure forecast only shows from the connection point forward
    showLine: true,
  };

  // Target line dataset
  const targetDataset = savingTarget > 0 ? {
    label: `Target (${savingTarget.toLocaleString()} VND)`,
    data: labels.length > 0 ? [
      // Start from the first actual date
      { x: labels[0], y: savingTarget },
      // End at the last forecast date (or last actual date if no forecast)
      { x: forecastLabels.length > 0 ? forecastLabels[forecastLabels.length - 1] : labels[labels.length - 1], y: savingTarget }
    ] : [],
    borderColor: "#ef4444",
    borderDash: [2, 2],
    backgroundColor: "rgba(239, 68, 68, 0.1)",
    tension: 0,
    spanGaps: true,
    pointRadius: 0,
    showLine: true,
  } : null;

  return (
    <div>
      <h2 className="text-xl font-semibold mb-4">Savings Jar Balance Over Time</h2>
      {loading ? (
        <div>Loading savings chart...</div>
      ) : labels.length === 0 ? (
        <div>No savings data available.</div>
      ) : (
        <Line
          data={{ datasets: [actualDataset, forecastDataset, targetDataset].filter(Boolean) }}
          options={{
            responsive: true,
            plugins: {
              legend: { position: "top" },
              title: { display: false },
            },
            scales: {
              x: {
                type: "time",
                time: { unit: "month" },
                title: { display: true, text: "Date" }
              },
              y: {
                beginAtZero: true,
                title: { display: true, text: "Balance (VND)" }
              }
            }
          }}
        />
      )}
      {forecastLoading && <div>Loading forecast...</div>}
    </div>
  );
}