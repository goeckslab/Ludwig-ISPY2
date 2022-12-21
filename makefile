DATA_DIRECTORY = ../ISPY-Data
DRUG = Paclitaxel
SCALED_DATASET = $(DRUG)_scaled_dataset.tsv
BASE_CONFIG = base_config.yaml

# Create scaled dataset.
$(SCALED_DATASET):
	python prepare_data.py "$(DATA_DIRECTORY)/mad_X_df.txt" "$(DATA_DIRECTORY)/y_df.txt" $(DRUG) $(SCALED_DATASET)

# Create final configuration file.
$(DRUG)_final_config.yaml: create_final_config.py base_config.yaml $(SCALED_DATASET)
	python create_final_config.py "$(SCALED_DATASET)" $(DRUG)_final_config.yaml $(BASE_CONFIG)

# Run a ludwig experiment using the scaled dataset. Results are placed into the $(DRUG) directory.
ludwig-experiment: $(DRUG)_final_config.yaml $(SCALED_DATASET)
	mkdir -p $(DRUG) && pushd $(DRUG) && ludwig experiment --dataset ../$(SCALED_DATASET) -c ../$(DRUG)_final_config.yaml -rs 456

clean:
	rm *final_config.yaml *_scaled_dataset.*

