# Score Breakdown Feature

## ✨ New Feature: Detailed Sustainability Score Breakdown

Users can now see exactly how sustainability scores are calculated with a comprehensive breakdown showing metrics, calculations, and carbon footprint estimates.

---

## 📊 What's Included

### 1. **Expandable Score Breakdown Card**
Located directly below the sustainability score on any product detail screen.

**Tap to expand and see:**
- Base score calculation
- Positive sustainability factors
- Negative environmental factors
- Carbon footprint estimate
- Final score calculation

---

## 🔍 Score Components

### **Base Score (Category-Based)**
Each product starts with a base score determined by its category:

| Category | Product Type | Base Score | Reasoning |
|----------|--------------|------------|-----------|
| Food & Grocery | Fresh Produce | 75 | Minimal processing, natural |
| Food & Grocery | Dairy/Cheese | 60 | Moderate environmental impact |
| Food & Grocery | Fish/Supplements | 70 | Health benefits, nutritional value |
| Food & Grocery | Processed Snacks | 35 | High packaging, sugar content |
| Personal Care | Disposable Razors | 40 | Generates waste |
| Personal Care | General | 55 | Moderate impact |
| Household | Appliances | 55 | Long-term use reduces waste |

---

### **Positive Factors** (Add Points)

| Factor | Points | Explanation |
|--------|--------|-------------|
| **Organic** | +20 | No synthetic pesticides or fertilizers |
| **Reusable** | +20 | Eliminates single-use waste |
| **Local** | +15 | Reduced transportation emissions |
| **Eco-friendly** | +15 | Environmentally conscious design |
| **Bamboo** | +15 | Sustainable, fast-growing material |
| **Recycled** | +15 | Reduces virgin material demand |
| **Wild-caught** | +10 | Natural sourcing, less farming impact |
| **Natural** | +10 | Minimal chemical processing |

---

### **Negative Factors** (Subtract Points)

| Factor | Points | Explanation |
|--------|--------|-------------|
| **Plastic** | -20 | Non-biodegradable, pollution risk |
| **Single-use** | -20 | Maximum waste generation |
| **Disposable** | -15 | Single-use generates waste |
| **Bottled** | -10 | Packaging waste, transport emissions |
| **Processed** | -10 | Energy-intensive manufacturing |

---

## 🌍 Carbon Footprint Estimates

The breakdown includes estimated CO₂ equivalent emissions:

### Food & Grocery
- **Fresh Produce**: ~0.5 kg CO₂e (Low impact)
- **Dairy/Cheese**: ~5.0 kg CO₂e (High dairy impact)
- **Fish/Seafood**: ~3.0 kg CO₂e (Moderate impact)
- **Average Food**: ~2.0 kg CO₂e

### Personal Care
- **General Products**: ~1.5 kg CO₂e

### Household
- **Appliances**: ~8.0 kg CO₂e (Manufacturing impact)

*Note: These are simplified estimates based on industry averages for typical product units.*

---

## 📐 Calculation Formula

```
Final Score = Base Score + Positive Factors + Negative Factors
Final Score = Clamped between 0 and 100
```

### Example: Avocados
```
Base Score:        75 pts  (Fresh produce)
Positive Factors:  +0 pts  (No special attributes detected)
Negative Factors:  -0 pts  (No negative attributes)
─────────────────────────
Final Score:       75/100
Carbon Footprint:  ~0.5 kg CO₂e
```

### Example: Wild Salmon Oil
```
Base Score:        70 pts  (Nutritional supplement)
Positive Factors:  +10 pts (Wild-caught)
Negative Factors:  -0 pts  (No negative attributes)
─────────────────────────
Final Score:       80/100
Carbon Footprint:  ~3.0 kg CO₂e
```

### Example: Gillette Razors
```
Base Score:        40 pts  (Disposable product)
Positive Factors:  +0 pts  (No special attributes)
Negative Factors:  -0 pts  (Already factored into base)
─────────────────────────
Final Score:       40/100
Carbon Footprint:  ~1.5 kg CO₂e
```

---

## 🎨 UI Features

### **Expandable Design**
- **Collapsed**: Shows "Score Breakdown" with analytics icon
- **Expanded**: Full detailed breakdown with color-coded sections

### **Visual Elements**
- 📊 **Section Headers**: Icons for each category
- 🟢 **Positive Factors**: Green badges with explanations
- 🔴 **Negative Factors**: Red badges with explanations
- 🟠 **Carbon Footprint**: Orange highlight box
- 📝 **Calculation Summary**: Step-by-step math
- ℹ️ **Methodology Note**: Transparency about calculations

### **Color Coding**
- **Blue**: Base score and final calculation
- **Green**: Positive sustainability attributes
- **Red**: Negative environmental impacts
- **Orange**: Carbon footprint data

---

## 🎯 User Benefits

1. **Transparency**: Users understand exactly why a product has its score
2. **Education**: Learn what makes products sustainable or not
3. **Trust**: See the methodology behind the numbers
4. **Informed Decisions**: Make better choices based on specific factors
5. **Carbon Awareness**: Understand environmental impact in concrete terms

---

## 📱 How to Use

1. **Scan a product** (barcode or receipt item)
2. **View the score** on the results screen
3. **Tap "Score Breakdown"** card to expand
4. **Review the details**:
   - See base category score
   - Check positive attributes
   - Review negative factors
   - View carbon footprint
   - Understand the calculation

---

## 🔬 Methodology

### **Data Sources**
- Category-based scoring from sustainability research
- Carbon footprint estimates from EPA and industry databases
- Attribute scoring based on environmental impact studies

### **Limitations**
- Estimates are simplified and averaged
- Actual impact varies by brand, sourcing, and production methods
- Carbon footprint is per typical unit (not exact weight)
- Some factors may not be detected from product names alone

### **Future Enhancements**
- Integration with real product databases
- More granular carbon calculations
- Water usage metrics
- Packaging impact analysis
- Supply chain transparency scores
- Seasonal and local availability data

---

## 💡 Example Scenarios

### **Scenario 1: Fresh Produce**
**Product**: Avocados  
**Score**: 75/100  
**Breakdown**:
- Base: 75 pts (Fresh produce)
- Carbon: 0.5 kg CO₂e
- **Why**: Natural, minimal processing, low emissions

### **Scenario 2: Organic Product**
**Product**: Organic Bananas  
**Score**: 95/100  
**Breakdown**:
- Base: 75 pts (Fresh produce)
- Organic: +20 pts
- Carbon: 0.5 kg CO₂e
- **Why**: Fresh + no pesticides = excellent choice

### **Scenario 3: Disposable Product**
**Product**: Plastic Water Bottles  
**Score**: 25/100  
**Breakdown**:
- Base: 50 pts (Beverages)
- Plastic: -20 pts
- Single-use: -20 pts
- Bottled: -10 pts
- Carbon: 2.0 kg CO₂e
- **Why**: Multiple negative factors compound

---

## 🚀 Technical Implementation

### **Files Modified**
- `lib/features/scan/scan_result_screen.dart`
  - Added `_calculateScoreBreakdown()` method
  - Created `_ScoreBreakdownCard` widget
  - Integrated expandable UI component

### **Key Components**
1. **Calculation Logic**: Mirrors `receipt_parser.dart` scoring
2. **Breakdown Data**: Structured map with all factors
3. **UI Widget**: Stateful expandable card
4. **Visual Design**: Color-coded, icon-based sections

---

## ✅ Testing

**Test the feature:**
1. Restart app: `flutter run`
2. Scan any product or receipt item
3. Look for "Score Breakdown" card below the score
4. Tap to expand
5. Review all sections:
   - Base score ✓
   - Positive factors ✓
   - Negative factors ✓
   - Carbon footprint ✓
   - Calculation summary ✓

---

This feature provides complete transparency into sustainability scoring, helping users make informed, eco-friendly purchasing decisions! 🌱
