using System;
using System.Globalization;
using System.Text.RegularExpressions;
namespace PSUTInternship.Shared {
    public static class PercentageRules {
        // Round cumulative contributions so a legacy 6/6 evaluation displays exactly 100%, not 100.02%.
        public static decimal RoundedContribution(decimal contribution, ref decimal rawTotal, ref decimal roundedTotal) {
            rawTotal += contribution;
            decimal next = Math.Round(rawTotal, 2, MidpointRounding.AwayFromZero);
            decimal result = next - roundedTotal; roundedTotal = next; return result;
        }
        public static bool TryParse(string value, out decimal percentage) {
            percentage = 0;
            return Regex.IsMatch(value ?? "", @"\A(?:100(?:\.0{1,2})?|(?:[0-9]|[1-9][0-9])(?:\.[0-9]{1,2})?)\z")
                && decimal.TryParse(value, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out percentage) && percentage >= 0 && percentage <= 100;
        }
    }
}