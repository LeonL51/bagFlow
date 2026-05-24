1. Link login_screen.dart to phoneNumber.dart so users can navigate from login to phone number authentication.
2. Build the phone number input UI with a country flag, country code, dropdown arrow, and phone number field.
3. Use a dependency like intl_phone_field, country_code_picker, or intl_phone_number_input instead of manually typing every country and country code.
4. Format the phone number input with hintText showing an example like (123) 456-7890.
5. Make the country flag and country code update dynamically when the user selects a different country.
6. Validate the phone number before moving to the OTP screen.
7. Show how to underline specific words inside one sentence using RichText and TextSpan.
8. Analyze the Flutter project for duplicated UI structures, styling, and logic across screens.
9. Refactor repeated UI into reusable widgets such as profile cards, settings tiles, switch tiles, icon bubbles, section headers, and bottom bars.
10. Move repeated colors, spacing, text styles, and button styles into a shared theme/helper file.
11. Suggest a clean Flutter folder structure using models, services, providers, screens, widgets, and utils.
12. Add Firebase dependencies for firebase_core, firebase_auth, and cloud_firestore.
13. Configure Firebase using flutterfire configure.
14. Initialize Firebase in main.dart without changing the current UI more than necessary.
15. Create auth_service.dart to handle login, signup, logout, current user, and password reset logic.
16. Create user_service.dart to handle Firestore user profile creation, reading, and updating.
17. Create preferences_service.dart to handle local settings like keep signed in, notifications, saved email, and welcome state.
18. Create expense.dart as the expense model with fields for id, userId, title, amount, category, date, recurring state, and createdAt.
19. Create expense_service.dart to add expenses, add multiple expenses, stream expenses, fetch all expenses, and delete all expenses from Firestore.
20. Create expense_provider.dart with Riverpod providers for the expense service, loading state, and real-time user expenses.
21. Fix provider and service typos such as pacakge, currentUSer, and Expense.frommap.
22. Update Firestore rules so users can read and write only their own users/{uid}/expenses/{expenseId} data.
23. Replace hard-coded Home screen expenses with expensesProvider.
24. Update Home screen tabs so Week, Month, and Year have dividers between them.
25. Center the Home screen total spent and remove the container around it.
26. Add weekly chart logic that shows the past 7 days from oldest to most recent with a trend line and expense amounts on the y-axis.
27. Add monthly chart logic that shows January through December with a bar chart.
28. Add yearly chart logic that shows the past 7 years with a bar chart.
29. Make Home charts update automatically when new expenses are added.
30. Add an expandable Insights section below the chart with a grey dropdown-style header and transparent expanded card.
31. Add an Insights tab switcher with Pie Chart and Breakdown tabs.
32. Build the Pie Chart tab to show category distribution based on the selected time filter.
33. In the Pie Chart tab, show category label, percentage of total spending, and actual amount spent.
34. Highlight the highest spending category in the Pie Chart tab.
35. Build the Breakdown tab to show most spent category, highest single transaction, total number of transactions, and comparison to the previous period.
36. Center the Recent Transactions title on Home.
37. Show the 7 most recent transactions on Home using real expense data.
38. Rebuild Add Expense screen with a category dropdown at the top.
39. Make the category dropdown open a bottom sheet or container with all categories.
40. After selecting a category, show item rows with vendor input and price input.
41. Make vendor options change based on selected category.
42. Add an Other vendor option that lets users manually type a custom vendor.
43. Fix the Other vendor behavior so selecting Other updates the field and makes it editable.
44. Add a centered circular plus button or add-row button so users can enter multiple expense items.
45. Show total label on the left and total value on the right for Add Expense.
46. Add a confirm/save button above the nav bar.
47. Save submitted expense rows to Firestore instead of returning local maps through Navigator.pop.
48. After saving expenses, navigate cleanly back to Home or Spending Log without causing a black screen.
49. Replace hard-coded Spending Log data with real expenses from expensesProvider.
50. Keep Spending Log search, category filtering, date filtering, grouped sections, and totals working with real expense data.
51. Replace hard-coded Planning spending values with calculations from real Firestore expenses.
52. Keep monthly budget and category budgets as temporary editable in-screen values until a budget settings feature or Firestore planning collection is built.
53. Make Planning screen calculate spent this month, remaining budget, safe-to-spend today, and budget progress dynamically.
54. Make Budget Forecast dynamic instead of hard-coded by projecting end-of-month spending from current monthly spending.
55. Show only the top 4 category budgets on the main Planning page.
56. Add a View All option for category budgets that switches to an all-categories page.
57. Add a back button on the all-categories page to return to the main Planning screen.
58. Let users adjust all category limits manually through a popup.
59. Format category limit inputs with clear category labels above each input field.
60. Make category limit input placeholder text and user input black inside white fields.
61. Add a Set Budget popup with the same clean input format as category limits.
62. Remove Plan Bills from Quick Actions.
63. Add a future-version Savings Goals section instead of keeping Create Goal only as a quick action.
64. Let users create savings goals with goal name, target amount, and amount already saved.
65. Show savings goal progress with saved amount, target amount, percentage, and progress bar.
66. Let users tap a savings goal to add more saved money.
67. Remove Create Goal from Quick Actions once Savings Goals has its own section.
68. Turn Planning Quick Actions into a vertical column instead of a row.
69. Keep only Set Budget and Adjust Category Limits in Planning Quick Actions.
70. Update More screen profile card to support profile image URL, name, and email.
71. Add edit_profile_screen.dart under lib/screens/navBar/.
72. Make Edit Profile allow users to update profile image URL and full name while displaying email as read-only.
73. Add settings_reset_password_screen.dart under lib/screens/navBar/.
74. Make Reset Password open a settings reset page instead of sending users back into the auth flow.
75. Make Reset Password send a reset link to the current logged-in user’s email.
76. Update More screen Preferences so Notifications uses the same switch style as Keep Me Signed In.
77. Make Keep Me Signed In persist using PreferencesService.
78. Make Notifications persist using PreferencesService.
79. Make Clear Data actually delete all user expenses from Firestore after confirmation.
80. Make Log Out actually sign out and route user back to login cleanly.
81. Keep Export Data as a real expense fetch placeholder that counts or prepares user expenses for later CSV export.
82. Preserve existing comments unless the related code is deleted or changed.
83. Remove unnecessary hard-coded expense data from Home, Spending Log, and Planning.
84. Keep necessary temporary values only when no real feature exists yet, such as editable budget limits before Firestore planning settings are added.
85. Ensure Home, Spending Log, Add Expense, Planning, and More all use real user data where possible.
86. Maintain current bottom navigation behavior across all tabs.
87. Keep the app’s dark UI style consistent across all screens.
88. Add clean commit messages for each major feature, including Firebase setup, expense model/service/provider, Home updates, Add Expense updates, Planning updates, More settings updates, and preferences service updates.