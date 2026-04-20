1. Link files login_screen.dart to phoneNumber.dart

2. I want my phone number to be in a row with a country flag along with a country code with a drop down arrow to change countries and country code based on the country they selected. Then use hintText that formats a phone number with an area code followed by the rest of the phone number 
- Are there any dependencies that I can make use of rather than typing out every country? 

3. How to add underline features to certain words in a line? 

4. Analyze the Flutter project and identify duplicated UI structures, styling, and logic across screens. Refactor the code by extracting shared components into reusable widgets, themes, or helper classes. Suggest a clean folder structure and maintain current functionality. 

5. Help me integrate Firebase into my Flutter app step by step. My project already has login, signup, forgot password, phone number, OTP, reset password, and welcome screens. I want to add Firebase Core, Firebase Authentication, and Firestore without changing the current UI more than necessary. Show me the exact dependencies to install, how to configure Firebase, how to initialize it in main.dart, and what repository/service files I should create first.

6. In homescreen, add a divider between each tab(week, month, and year). then, center the total spent while getting rid of the container around it. after that, turn the second white card section into a grey dropdown button that returns a transparent card that would later include a pie chart and insight information. the final part follows with a recent transaction title that is centered. Underneatht that would include the 7 most recent transactions.

7. Insert a chart for each time frame: for the weekly, I need a chart with x axis that dates the past 7 days individually from oldest to most recent date(e.g. 1, 2, 3, 4, 5) with a trend line and the y axis would be based on the amount of expenses. For the monthly, everything else stays the same, except it's every month from January to December with a histogram displaying the trend. Finally, for yearly, it would date the past 7 years with histograms to show the trend again. This chart should goes beneath total spent. Make sure it takes into account the addition of new expenses recorded. 

8. Add an Insights section below the existing chart that uses two tabs: Pie chart and Breakdown. The section should update based on the selected time filter (week, month, year). The UI should be simple and clean, with a tab switcher below the chart and a dynamic content area that updates instantly when switching tabs.

9. The Pie Chart tab displays a pie chart showing how spending is distributed across categories. It should include a list of each category with its label, percentage of total spending, and the actual amount spent within the selected time frame. It should also highlight which category has the highest spending. The UI should be simple and clean, with a tab switcher below the chart and a dynamic content area that updates instantly when switching tabs.

10. The Breakdown tab provides a concise summary of spending behavior. It should include the most spent category, the highest single transaction (amount and merchant), the total number of transactions, and how spending compares to the previous time period. The UI should be simple and clean, with a tab switcher below the chart and a dynamic content area that updates instantly when switching tabs.

11. Here is the idea for my add expense screen: its going to start with a category dropdown bar that when pressed on, its going to have a container that contains all these different categories, then it would be followed by a row of 2 columns. the first column would include vendors that users can choose from depending on the category that was they selected(include an other option) for users to manually input the restaurant. On the other half, allow users to input the price. Following this part, have a centered circular plus button that allows users to input new items if need be. Following this, include the total on the far left and the value on the far right. then right above the nav bar, include a confirm button for users to submit their entires. this will change data throughout other files




