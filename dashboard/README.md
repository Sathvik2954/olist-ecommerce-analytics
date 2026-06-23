# Power BI Dashboard Setup Guide

This guide helps you set up the Olist E-Commerce analytics dashboard in Power BI Desktop step-by-step.

---

## 🔌 1. Data Connection

1. Open **Power BI Desktop**.
2. Click **Get Data** → **MySQL database**.
3. Set **Server** to `localhost` and **Database** to `olist_db`.
4. Import these 7 tables:
   - `orders`
   - `order_items`
   - `customers`
   - `payments`
   - `reviews`
   - `products`
   - `category_translation`
5. Click **Load**.

---

## 📐 2. Data Model & Relationships

Open the **Model view** (diagram icon on the left sidebar) and verify or manually build the following relationships:

- **orders** `[order_id]` (1) ─── (多く/*) **order_items** `[order_id]` (One-to-Many)
- **orders** `[customer_id]` (*) ─── (1) **customers** `[customer_id]` (Many-to-One)
- **orders** `[order_id]` (1) ─── (多く/*) **payments** `[order_id]` (One-to-Many)
- **orders** `[order_id]` (1) ─── (多く/*) **reviews** `[order_id]` (One-to-Many)
- **order_items** `[product_id]` (*) ─── (1) **products** `[product_id]` (Many-to-One)
- **products** `[product_category_name]` (*) ─── (1) **category_translation** `[product_category_name]` (Many-to-One)
- **sellers** `[seller_id]` (1) ─── (多く/*) **order_items** `[seller_id]` (One-to-Many)

*Note: Ensure the filter direction flows from dimension tables to fact tables (e.g., from customers to orders).*

---

## 🧮 3. DAX Calculated Columns

In the **Data view**, select the `'olist_db orders'` table and create these new calculated columns:

### Column 1: `Delivery Status`
Click **New Column** and paste:
```dax
Delivery Status = 
IF(
    ISBLANK('olist_db orders'[order_delivered_customer_date]),
    "Not Delivered",
    IF(
        'olist_db orders'[order_delivered_customer_date] <= 'olist_db orders'[order_estimated_delivery_date],
        "On Time or Early",
        IF(
            DATEDIFF('olist_db orders'[order_estimated_delivery_date], 'olist_db orders'[order_delivered_customer_date], DAY) <= 3,
            "Late 1-3 Days",
            "Late 4+ Days"
        )
    )
)
```

### Column 2: `Delivery Days`
Click **New Column** and paste:
```dax
Delivery Days = 
IF(
    ISBLANK('olist_db orders'[order_delivered_customer_date]),
    BLANK(),
    DATEDIFF('olist_db orders'[order_purchase_timestamp], 'olist_db orders'[order_delivered_customer_date], DAY)
)
```

---

## 📊 4. DAX Measures

Select the `'olist_db orders'` table and click **New Measure** in the top ribbon to create the following 6 measures:

### Measure 1: `Total Revenue`
```dax
Total Revenue = SUM('olist_db order_items'[price]) + SUM('olist_db order_items'[freight_value])
```

### Measure 2: `Total Orders`
```dax
Total Orders = DISTINCTCOUNT('olist_db orders'[order_id])
```

### Measure 3: `Avg Order Value`
```dax
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
```

### Measure 4: `Avg Review Score`
```dax
Avg Review Score = AVERAGE('olist_db reviews'[review_score])
```

### Measure 5: `On Time Delivery %`
```dax
On Time Delivery % = 
VAR DeliveredOrders = 
    CALCULATE(
        COUNTROWS('olist_db orders'),
        'olist_db orders'[Delivery Status] <> "Not Delivered"
    )
VAR OnTimeOrders = 
    CALCULATE(
        COUNTROWS('olist_db orders'),
        'olist_db orders'[Delivery Status] = "On Time or Early"
    )
RETURN
DIVIDE(OnTimeOrders, DeliveredOrders) * 100
```

### Measure 6: `Repeat Customer %`
```dax
Repeat Customer % = 
VAR CustomerTable = 
    ADDCOLUMNS(
        VALUES('olist_db customers'[customer_unique_id]),
        "OrderCount", CALCULATE(DISTINCTCOUNT('olist_db orders'[order_id]))
    )
VAR RepeatCustomers = 
    COUNTROWS(FILTER(CustomerTable, [OrderCount] > 1))
VAR TotalCustomers = 
    COUNTROWS(CustomerTable)
RETURN
DIVIDE(RepeatCustomers, TotalCustomers) * 100
```

---

---

## 🎨 5. Visualizations Design & Layout (Step-by-Step)

Open the **Report view** (chart icon on the far left sidebar) to begin building your pages. Rename your tabs at the bottom by double-clicking them.

### 📄 PAGE 1: Business Overview
Rename this tab to **Business Overview**.

#### Visual 1: KPI Cards (Top Row)
1. Click the **Card (New)** or **Card** icon in the **Visualizations** pane on the right.
2. Drag `Total Revenue` from the `'olist_db orders'` table into the **Fields** / **Data** well.
3. Repeat this process to create 3 more separate card visuals for:
   - `Total Orders`
   - `Avg Order Value`
   - `Avg Review Score`
4. Arrange the 4 cards horizontally along the top of the page.

#### Visual 2: Monthly Revenue Line Chart
1. Click the **Line Chart** icon in the **Visualizations** pane.
2. Position it on the left side of the page, below the KPI cards.
3. In the **Data** pane:
   - Drag `'olist_db orders'[order_purchase_timestamp]` to the **X-axis**. Click the down-arrow next to it and select **order_purchase_timestamp** (not the Date Hierarchy) to show monthly dates.
   - Drag the `Total Revenue` measure to the **Y-axis**.
4. In the **Filters** pane on the right:
   - Drag `'olist_db orders'[order_status]` to **Filters on this visual**.
   - Select **Basic filtering** and check the box next to **delivered**.
5. Change the title:
   - Click the **Format visual** icon (paintbrush) in the Visualizations pane.
   - Go to **General** tab → **Title** and write:
     `Revenue grew steadily from early 2017 to late 2018`

#### Visual 3: Top 10 Categories Bar Chart
1. Click the **Clustered Bar Chart** (horizontal bar chart) icon in the **Visualizations** pane.
2. Position it on the right side of the page, next to the line chart.
3. In the **Data** pane:
   - Drag `'olist_db category_translation'[product_category_name_english]` to the **Y-axis**.
   - Drag the `Total Revenue` measure to the **X-axis**.
4. In the **Filters** pane:
   - Click `'olist_db category_translation'[product_category_name_english]` under **Filters on this visual**.
   - Change **Filter type** to **Top N**.
   - Under **Show items**, enter `10`.
   - In the **By value** well, drag the `Total Revenue` measure.
   - Click **Apply filter** at the bottom of that box.
5. Change the title:
   - Go to the **Format visual** (paintbrush) → **General** → **Title** and enter:
     `Health & Beauty and Watches generate the highest revenue`

---

### 📄 PAGE 2: Delivery & Satisfaction
Click the `+` button at the bottom of the screen to create a new tab. Rename it to **Delivery & Satisfaction**.

#### Visual 1: Review Score by Delivery Status Bar Chart
1. Click the **Clustered Bar Chart** (horizontal) icon in the **Visualizations** pane.
2. Position it on the left side of the page.
3. In the **Data** pane:
   - Drag `'olist_db orders'[Delivery Status]` to the **Y-axis**.
   - Drag the `Avg Review Score` measure to the **X-axis**.
4. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** and enter:
     `Late deliveries (4+ days) drop review scores to 1.86 stars`

#### Visual 2: Delivery Performance by State Table
1. Click the **Table** icon in the **Visualizations** pane.
2. Position it on the right side of the page.
3. In the **Data** pane, drag these columns into the **Columns** well in order:
   - `'olist_db customers'[customer_state]`
   - `'olist_db orders'[order_id]` (After dragging, click the down-arrow next to it and choose **Count (Distinct)**)
   - `'olist_db orders'[Delivery Days]` (After dragging, click the down-arrow next to it and choose **Average**)
4. Sort the table: Click on the **Average of Delivery Days** column header in your table visual to sort it descending (highest delivery times at the top).
5. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** (toggle it ON) and write:
     `Northern states average 5 to 10 more days in delivery vs. southeastern states`

#### Visual 3: On-Time KPI Card
1. Click the **Card** visual icon in the **Visualizations** pane.
2. Position it below the table or in a clean corner.
3. Drag the `On Time Delivery %` measure to the **Fields** well.
4. Format as percentage: Click the `On Time Delivery %` measure in your data pane, then go to **Measure tools** on the top menu and click the **%** symbol.
5. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** (toggle ON) and enter:
     `97% of orders delivered on or before estimated date`

---

### 📄 PAGE 3: Customers & Sellers
Click the `+` button at the bottom to add a third tab. Rename it to **Customers & Sellers**.

#### Visual 1: Repeat Purchase Rate Card
1. Click the **Card** visual icon.
2. Drag the `Repeat Customer %` measure to the **Fields** well.
3. Format as percentage: Select the measure in the pane, click **Measure tools** in the top menu, and select **%**.
4. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** (toggle ON) and enter:
     `3.0% customer repeat purchase rate`

#### Visual 2: Top 10 Sellers by Revenue Bar Chart
1. Click the **Clustered Bar Chart** (horizontal) icon.
2. Position it on the left half of the page.
3. In the **Data** pane:
   - Drag `'olist_db order_items'[seller_id]` to the **Y-axis**.
   - Drag the `Total Revenue` measure to the **X-axis**.
4. In the **Filters** pane:
   - Click `'olist_db order_items'[seller_id]` under **Filters on this visual**.
   - Select **Top N** filter type, enter `10` in **Show items**, and drag the `Total Revenue` measure to **By value**.
   - Click **Apply filter**.
5. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** and write:
     `Top 10 sellers contribute significant share of BRL sales`

#### Visual 3: Payment Method Mix Bar Chart
1. Click the **Clustered Bar Chart** (horizontal) icon.
2. Position it on the right half of the page.
3. In the **Data** pane:
   - Drag `'olist_db payments'[payment_type]` to the **Y-axis**.
   - Drag `'olist_db payments'[order_id]` to the **X-axis** (Click the down-arrow next to it and select **Count** or **Count (Distinct)**).
4. Sort descending: Click the three dots `...` on the top-right corner of the chart visual -> **Sort axis** -> Select **Count of order_id** and make sure **Sort descending** is selected.
5. Change the title:
   - Go to **Format visual** (paintbrush) → **General** → **Title** and write:
     `Credit card is the dominant payment method at 73.9% of orders`

---

## 💾 6. Save & Export Screenshots

### Step 1: Save the Dashboard File
- Click **File** → **Save As**.
- Save the file with the exact name: `olist_dashboard.pbix`
- Save it inside the `dashboard/` directory of your local repository `olist-ecommerce-analytics/dashboard/`.

### Step 2: Take and Save Screenshots
- Navigate to the **Business Overview** tab in Power BI.
- Take a screenshot of the dashboard page (press `Win + Shift + S` on your keyboard, drag over the dashboard visual, and save the captured image).
- Save it as:
  `dashboard_page1_overview.png`
- Repeat the process for the remaining pages, saving them as:
  `dashboard_page2_delivery.png`
  `dashboard_page3_customers.png`
- Place all three images inside the `dashboard/screenshots/` folder of your project workspace.

*Once they are saved in that folder, your repository README.md will automatically display your dashboard visuals.*

