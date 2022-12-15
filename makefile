DATA_DIRECTORY = .
DRUG = PaclitaxelAndPembrolizumab
SCALED_DATASET = $(DRUG)_scaled_dataset.tsv

# Create scaled dataset.
$(SCALED_DATASET):
	python prepare_data.py "$(DATA_DIRECTORY)/mad_X_df.txt" "$(DATA_DIRECTORY)/y_df.txt" $(DRUG) $(SCALED_DATASET)

# Create final configuration file.
$(DRUG)_final_config.yaml: create_input_features.py base_config.yaml $(SCALED_DATASET)
	python create_input_features.py "$(SCALED_DATASET)" $(DRUG)_input_features.yaml; cat $(DRUG)_input_features.yaml base_config.yaml > $(DRUG)_final_config.yaml

# Run a ludwig experiment using the scaled dataset. Results are placed into the $(DRUG) directory.
ludwig-experiment: $(DRUG)_final_config.yaml $(SCALED_DATASET)
	mkdir -p $(DRUG) && pushd $(DRUG) && ludwig experiment --dataset ../$(SCALED_DATASET) --config ../$(DRUG)_final_config.yaml -rs 456

clean:
	rm *final_config.yaml *_scaled_dataset.*

